---
description: タスクの追加・一覧・完了・更新・レビュー確認を行う
---

以下の入力内容を処理してください。

## 処理手順

1. **操作の判定**
   - `$ARGUMENTS` のキーワードに応じて以下の操作を実行:

2. **タスク追加**（キーワード: 追加、add）
   - `mcp__dailymemo__add_task` で新規タスクを作成
   - パラメータ: title, status?（デフォルト: "planned", icebox/planned/in-progress/on-hold から選択）, start?, due?, review?
   - 作成後、WIP制限の確認: in-progress のタスクが5件以上ある場合は警告を表示

3. **タスク一覧**（キーワード: 一覧、list、リスト）
   - `mcp__dailymemo__list_tasks` で一覧表示
   - パラメータ: status?（デフォルト: "all", all/open/done/icebox/planned/in-progress/on-hold/cancelled から選択）, dueBefore?, dueAfter?

4. **タスク完了**（キーワード: 完了、done、close）
   - `mcp__dailymemo__complete_task` でタスクを完了にする
   - パラメータ: title, date?
   - タイトルが曖昧な場合は `mcp__dailymemo__list_tasks` で一覧を表示し、ユーザーに対象を選択してもらう

5. **タスク更新**（キーワード: 更新、update、変更）
   - `mcp__dailymemo__update_task` でタスクを更新する
   - パラメータ: title, newTitle?, status?（icebox/planned/in-progress/on-hold/done/cancelled）, start?, due?, review?, addLink?, linkText?
   - タイトルが曖昧な場合は `mcp__dailymemo__list_tasks` で一覧を表示し、ユーザーに対象を選択してもらう
   - status を in-progress に変更する場合、WIP制限の確認: in-progress のタスクが5件以上ある場合は警告を表示

6. **レビュー確認**（キーワード: レビュー、review）
   - `mcp__dailymemo__review_tasks` でレビュー対象タスクを表示
   - パラメータ: date?

## 入力内容

$ARGUMENTS
