---
model: Haiku
name: ccc
description: コードを意味で検索する。実装やロジックの場所を概念・自然言語で探したいとき(grep で当てにくいとき)に使う。
---

# cocoindex-code (ccc) — セマンティックコード検索

コードを**意味で検索**する。キーワードの一致ではなく概念で探すため、正確な名前を知らなくても関連箇所を見つけられる。grep / text search が苦手な「○○している処理はどこか」に強い。

## 使い方

`cocoindex-code` MCP サーバの **`search` ツール**(`mcp__cocoindex-code__search`)を呼ぶ。

- `query` に**自然言語**かコード片を渡す(例: "error handling middleware"、"slack に通知を送る処理"、"permission check")
- 必要に応じて絞り込む:
  - 言語フィルタ(例: python, go)
  - ファイルパスの GLOB(例: `src/utils/*`)
  - 件数

## 結果の扱い

返り値は以下を持つ。これを元に該当ファイルを開いて精読する。

- `file_path` — 相対パス
- `start_line` / `end_line` — 行範囲
- `language` — 言語
- `content` — コード本体
- `score` — 類似度(0-1、高いほど関連)

## 使う場面

- 「○○を実装している箇所」「××の処理はどこ」を概念で探すとき
- 不慣れな codebase で実装の在り処を当てたいとき
- grep のキーワードが思いつかない／表記揺れがあるとき

## 注意

`mcp__cocoindex-code__search` が見つからない場合、その repo は未索引(MCP 未接続)。索引済みの repo 内で Claude Code を起動する必要がある。
