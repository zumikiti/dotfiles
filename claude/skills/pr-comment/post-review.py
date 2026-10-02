#!/usr/bin/env python3
"""
PR にインラインレビューコメントをまとめて投稿する。

入力 JSON:
{
  "pr": 789,
  "event": "COMMENT",              # 省略時 COMMENT。APPROVE / REQUEST_CHANGES も可
  "body": "全体コメント（任意）",
  "comments": [
    {"path": "app/Foo.php", "line": 267, "label": "issue", "body": "..."}
  ]
}

label は conventional comments の種別。本文の先頭に "label: " を付けて投稿する。
投稿前に、各 (path, line) が PR 差分の RIGHT 側ハンク内にあることを検証する
（差分外の行には GitHub がインラインコメントを付けられず 422 になる）。

使い方:
  post-review.py comments.json --dry-run   # 検証 + 投稿ペイロードを表示
  post-review.py comments.json             # 投稿
"""

import json
import re
import subprocess
import sys

LABELS = {'issue', 'suggestion', 'q', 'nits', 'imo', 'thought', 'praise', 'todo', 'chore', 'note'}
HUNK_RE = re.compile(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')


def gh(*args: str, input_: str | None = None) -> str:
    result = subprocess.run(['gh', *args], input=input_, text=True, capture_output=True)
    if result.returncode != 0:
        sys.exit(f'gh {" ".join(args)} failed:\n{result.stderr}')
    return result.stdout


def right_side_ranges(diff: str) -> dict[str, list[tuple[int, int]]]:
    """path => [(start, end), ...] コメント可能な RIGHT 側の行範囲"""
    ranges: dict[str, list[tuple[int, int]]] = {}
    path = None
    for line in diff.splitlines():
        if line.startswith('+++ b/'):
            path = line[6:]
            ranges.setdefault(path, [])
        elif line.startswith('@@') and path is not None:
            m = HUNK_RE.match(line)
            if m:
                start = int(m.group(1))
                count = int(m.group(2) or 1)
                ranges[path].append((start, start + count - 1))
    return ranges


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    dry_run = '--dry-run' in sys.argv
    with open(sys.argv[1], encoding='utf-8') as f:
        spec = json.load(f)

    pr = str(spec['pr'])
    repo = json.loads(gh('repo', 'view', '--json', 'nameWithOwner'))['nameWithOwner']
    head = json.loads(gh('pr', 'view', pr, '--json', 'headRefOid'))['headRefOid']
    ranges = right_side_ranges(gh('pr', 'diff', pr))

    errors = []
    comments = []
    for c in spec['comments']:
        label = c.get('label', '')
        if label not in LABELS:
            errors.append(f'{c["path"]}:{c["line"]} 不明な label "{label}"（{", ".join(sorted(LABELS))}）')
        file_ranges = ranges.get(c['path'])
        if file_ranges is None:
            errors.append(f'{c["path"]} は PR 差分に含まれていません')
        elif not any(s <= c['line'] <= e for s, e in file_ranges):
            hint = ', '.join(f'{s}-{e}' for s, e in file_ranges)
            errors.append(f'{c["path"]}:{c["line"]} は差分外です。コメント可能な行: {hint}')
        comments.append({
            'path': c['path'],
            'line': c['line'],
            'side': 'RIGHT',
            'body': f'{label}: {c["body"]}' if label else c['body'],
        })
    if errors:
        sys.exit('検証エラー:\n  ' + '\n  '.join(errors))

    payload = {
        'commit_id': head,
        'event': spec.get('event', 'COMMENT'),
        'comments': comments,
    }
    if spec.get('body'):
        payload['body'] = spec['body']

    if dry_run:
        print(f'# {repo} PR #{pr} @ {head[:8]} — {len(comments)} comments (dry-run)')
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return

    out = gh('api', '-X', 'POST', f'repos/{repo}/pulls/{pr}/reviews', '--input', '-', input_=json.dumps(payload))
    review = json.loads(out)
    print(f'{review["state"]}: {review["html_url"]}')


if __name__ == '__main__':
    main()
