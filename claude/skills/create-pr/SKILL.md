---
description: Draft Pull Requestを自動作成
---

現在のブランチから Draft Pull Request を作成してください。

## 手順

### 1. ブランチ情報の収集

以下を並列で実行:
- `git branch --show-current` で現在のブランチ名を取得
- `git status -u` で未コミットの変更を確認
- `git remote show origin` でリモートのHEAD（デフォルトブランチ）を確認

### 2. ベースブランチの自動判定

- `$ARGUMENTS` でベースブランチが指定されている場合はそれを使用する
- 指定がない場合は `main`（または `master`）をベースブランチ候補とし、ユーザーに確認してから進める

### 3. 差分の確認

- `git log origin/<ベースブランチ>..HEAD --oneline` でコミット一覧を取得
- `git diff origin/<ベースブランチ>...HEAD --stat` で変更ファイル一覧を取得
- `git diff origin/<ベースブランチ>...HEAD` で差分の詳細を確認

### 4. JiraチケットIDの抽出

ブランチ名から `GCK16-\d+` パターンのチケットIDを抽出する。
- 見つかった場合: `https://stafes.atlassian.net/browse/<チケットID>` をURLとして使用
- 見つからない場合: `- N/A` とする

### 5. PRの作成

`.github/pull_request_template.md`（または `.github/PULL_REQUEST_TEMPLATE.md`）をベースに、差分・コミットログを分析してdescriptionを生成する。

- タイトル: コミットメッセージを要約（70文字以内）
- ベースブランチ: 手順2で判定したブランチ
- **必ず `--draft` で作成すること**
- PRのdescriptionは日本語で記述する
- 「忘れがちな検証項目」セクションは変更内容に関係のある項目のみ残す
- 動作確認セクションはドキュメントのみの変更の場合「ドキュメントの変更のみのため、動作確認は不要」とする

### 6. 結果の報告

作成したPRのURLを表示する。
