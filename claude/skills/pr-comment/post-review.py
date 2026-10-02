#!/usr/bin/env python3
"""
PR にインラインレビューコメントをまとめて投稿する。

使い方:
  post-review.py comments.json --dry-run   # 検証 + 投稿ペイロードを表示
  post-review.py comments.json             # 投稿

入力 JSON の形式・label の種別・検証内容は同じディレクトリの SKILL.md を参照。
投稿前に各 (path, line) が PR 差分の RIGHT 側ハンク内にあることを検証し、
1 件でも失敗すれば何も投稿せず exit 1 で止める。
"""

from __future__ import annotations

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


def hunk_ranges(patch: str) -> list[tuple[int, int]]:
    """patch 文字列から RIGHT 側ハンクの (start, end) を取り出す。end < start は 0 行ハンク（純削除）"""
    ranges = []
    for line in patch.splitlines():
        m = HUNK_RE.match(line)
        if m:
            start = int(m.group(1))
            count = int(m.group(2) or 1)
            ranges.append((start, start + count - 1))
    return ranges


def right_side_ranges(pr: str) -> dict[str, list[tuple[int, int]]]:
    """path => [(start, end), ...] コメント可能な RIGHT 側の行範囲。
    `gh pr diff` の `+++ b/` 行はパスに引用符やタブが混ざるので、API の filename / patch を使う"""
    out = gh('api', f'repos/{{owner}}/{{repo}}/pulls/{pr}/files', '--paginate', '--jq', '.[] | {filename, patch}')
    ranges = {}
    for line in out.splitlines():
        f = json.loads(line)
        ranges[f['filename']] = hunk_ranges(f['patch'] or '')  # patch はバイナリ・巨大ファイルで null
    return ranges


def main() -> None:
    args = [a for a in sys.argv[1:] if a != '--dry-run']
    if len(args) != 1:
        sys.exit(__doc__)
    dry_run = len(args) != len(sys.argv) - 1
    with open(args[0], encoding='utf-8') as f:
        spec = json.load(f)

    pr = str(int(spec['pr']))
    info = json.loads(gh('pr', 'view', pr, '--json', 'headRefOid,url'))
    head = info['headRefOid']
    ranges = right_side_ranges(pr)

    errors = []
    comments = []
    for c in spec['comments']:
        path, line, label = c.get('path'), c.get('line'), c.get('label')
        if not path or type(line) is not int or not c.get('body'):  # bool は int 扱いなので isinstance は使わない
            errors.append(f'{path}:{line!r} path / line（整数）/ body は必須です')
            continue
        if label not in LABELS:
            errors.append(f'{path}:{line} 不明な label "{label}"（{", ".join(sorted(LABELS))}）')
        file_ranges = ranges.get(path)
        if file_ranges is None:
            errors.append(f'{path} は PR 差分に含まれていません')
        elif not any(s <= line <= e for s, e in file_ranges):
            hint = ', '.join(f'{s}-{e}' for s, e in file_ranges if s <= e)
            errors.append(f'{path}:{line} は差分外です。コメント可能な行: {hint or "なし"}')
        comments.append({
            'path': path,
            'line': line,
            'side': 'RIGHT',
            'body': f'{label}: {c["body"]}',
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
        print(f'# {info["url"]} @ {head[:8]} — {len(comments)} comments (dry-run)')
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return

    out = gh('api', '-X', 'POST', f'repos/{{owner}}/{{repo}}/pulls/{pr}/reviews', '--input', '-', input_=json.dumps(payload))
    review = json.loads(out)
    print(f'{review["state"]}: {review["html_url"]}')


if __name__ == '__main__':
    main()
