---
name: pr-comment
description: |
  /pr-review などレビュー結果の指摘のうち、ユーザーが選んだものを conventional comments の種別（issue / suggestion / q / nits / imo …）を付けて
  PR のインラインレビューコメントとして投稿する。「1,2,3 をコメントして」「この指摘を nits で投稿」「PRにレビューコメントして」等の依頼で使用する。
  投稿前に行番号が差分内か検証し、文面をユーザーに見せてから投稿する。
allowed-tools:
  - Bash
  - Read
  - Write
  - Agent
  - Skill
---

# PR インラインコメント投稿

レビュー結果（主に `/pr-review` の出力）から選んだ指摘を、種別付きの短いインラインコメントにして PR へ投稿する。
ドライバは `~/.claude/skills/pr-comment/post-review.py`（Python 3 標準ライブラリ + `gh` のみ）。

## 使用方法
```
/pr-comment <PR番号> <指摘番号...>     例: /pr-comment 789 1,2,3,6
```
直前に `/pr-review` の結果が無い場合は、何をコメントするかユーザーに確認する。

## 手順

1. **対象 PR のリポジトリで実行する**（ドライバは `gh repo view` でカレントのリポジトリを解決する）
2. **文面を作る** — 指摘ごとに `{path, line, label, body}` を組む。文面作成は判断を伴うため、まとまった件数なら subagent-model-policy に従いサブエージェントに委譲してよい。サブエージェントには **投稿させない**（JSON を返させるだけ）
3. **JSON をスクラッチパッドに書く**（下記フォーマット）
4. **dry-run** で検証と投稿ペイロードの確認
   ```bash
   ~/.claude/skills/pr-comment/post-review.py <scratchpad>/comments.json --dry-run
   ```
5. **文面をユーザーに見せる**（表: 行 / 種別 / 要旨）。投稿は外に出る操作ゆえ、ユーザーが「投稿して」と明示していない限りここで止める
6. **投稿**
   ```bash
   ~/.claude/skills/pr-comment/post-review.py <scratchpad>/comments.json
   ```
   出力の `COMMENTED: https://github.com/.../pull/N#pullrequestreview-...` をユーザーに返す

## 入力 JSON

```json
{
  "pr": 789,
  "event": "COMMENT",
  "body": "全体コメント（任意・通常は省略）",
  "comments": [
    {"path": "app/QueryProcessor/Review/ProductReviewImportCsvQueryProcessor.php", "line": 267,
     "label": "issue", "body": "空欄判定はtrim後ですが、toDtoでは生の値を使っています。"}
  ]
}
```

- `event` 省略時は `COMMENT`。`APPROVE` / `REQUEST_CHANGES` はユーザーが明示したときだけ
- `label` はドライバが本文の先頭に `label: ` として付ける。本文側には書かない

## 種別（label）の使い分け

| label | 使うとき |
|---|---|
| `issue` | 直さないと不具合になる。根拠となる具体的な入力→結果を1つ添える |
| `suggestion` | 直したほうがよいが必須ではない。代替案を1行で |
| `q` | 意図の確認。「〜は意図どおりですか？」で終える |
| `nits` | 命名・定数化・整形など。1文 |
| `imo` | 設計上の好み。「〜のほうがよさそうです」程度に留める |
| `thought` | 対応不要の気づき・将来の話 |
| `praise` | 良い点。使うなら具体的に |
| `todo` / `chore` / `note` | 補助的。まれ |

## 文面の作法（限定合理性）

- 読み手は忙しい同僚。**1コメント = 目安120字、最大2文 + 任意で1行のコード例**
- 前置き・褒め言葉・作者が知っている文脈の再説明は書かない
- `issue` は「入力 → 起きること → 最小の直し方」の順
- 後続 PR（スタックしている PR）があるなら「この PR で直すと #NNN のリベース差分も小さくなる」のように、直す動機を1句だけ添える
- インラインで指したい行が差分外なら、同じ関数内で差分内の最寄り行に付け、本文で本来の場所（メソッド名や式）を示す

## ドライバの検証内容

`--dry-run` 有無にかかわらず投稿前に検証し、1つでも失敗すれば何も投稿せず exit 1:
- `path` が PR 差分に含まれている
- `line` が RIGHT 側ハンク（追加行・文脈行）の範囲内。外れていればコメント可能な行範囲を表示する
- `label` が上表のいずれか

## Gotchas

- **差分外の行にはインラインコメントを付けられない**（GitHub API が 422 を返す）。ドライバが弾くので、表示された範囲から最寄りの行を選び直す
- `gh pr diff` の `+++ b/` 行からパスを取っているため、**リネームされたファイルは新しいパス**で指定する
- `commit_id` は実行時点の PR HEAD。ユーザーに文面を見せている間に push されると行がずれる。投稿直前に dry-run をやり直せば HEAD と範囲が更新される
- `label` は `nit` ではなく `nits`、`question` ではなく `q`（表の綴りに固定している）

## 検証済みの範囲

- PR に対し、dry-run で正常系（2件）と異常系（差分外行・label 誤り・差分外ファイル）を確認済み
- 実投稿は同一ペイロード形式を `gh api -X POST repos/{owner}/{repo}/pulls/{n}/reviews --input` で手動投稿して成功したもの（`state: COMMENTED`）。ドライバ経由の実投稿は本物の PR にテストコメントを残すため未実施
