---
description: 今日の日報にメモや学びを追記する・タスクを管理する
---

以下の入力内容を処理してください。

## 処理手順

1. **インテント判定**
   - `$ARGUMENTS` を分析し、「タスク操作」か「メモ追記」かを判定
   - タスク系キーワード（「タスク追加」「タスク一覧」「タスク完了」「タスク更新」等）を含む → ステップ5（タスク操作）へ
   - それ以外 → ステップ2〜4（メモ追記）へ

2. **日付の決定**
   - 引数に日付（YYYY-MM-DD形式）が含まれている場合はその日付を使用
   - 日付の指定がない場合は本日の日付を使用

3. **日次エントリの存在確認**
   - `mcp__dailymemo__get_report` で該当日付の日次エントリが存在するか確認
   - 日次エントリが存在しない場合（"Day entry for {date} not found in monthly report" エラー）:
     - ユーザーに「{日付}の日次エントリが存在しません。新規作成してもよいですか？」と確認
     - ユーザーが承諾した場合のみ `mcp__dailymemo__create_daily_report` で作成

4. **メモの追記**
   - 日報の内容を確認し、追記内容に最も適したセクションを選択
   - セクション一覧:
     - 作業内容・実装の詳細 → 「本日の作業内容」
     - 進捗報告・成果物 → 「進捗・成果」
     - 学び・知見・Tips → 「メモ」
     - 問題・課題 → 「課題・懸念事項」
     - 明日やること → 「明日の予定」
   - 選択したセクションに `mcp__dailymemo__append_to_report` で追記
   - **見出しの先頭に【{現在の作業ディレクトリ名}】を付与すること**（例: 【my-app】、【api-server】）
   - 簡潔かつ後から見返して理解できる形式で記述すること
   - コードサンプルがある場合は適切なマークダウン形式で記載すること

5. **タスク操作**
   - `$ARGUMENTS` のキーワードに応じて以下の操作を実行:
   - **タスク追加**: `mcp__dailymemo__add_task` で新規タスクを作成（title, due?, start?）
   - **タスク一覧**: `mcp__dailymemo__list_tasks` で一覧表示（status: デフォルト open, dueAfter?, dueBefore?）
   - **タスク完了**: `mcp__dailymemo__complete_task` でタスクを完了にする（title, date?）
   - **タスク更新**: `mcp__dailymemo__update_task` でタスクを更新する（title, newTitle?, due?, start?, addLink?, linkText?）
   - タスク完了・更新時にタイトルが曖昧な場合は `mcp__dailymemo__list_tasks` で一覧を表示し、ユーザーに対象を選択してもらう

## 入力内容

$ARGUMENTS
