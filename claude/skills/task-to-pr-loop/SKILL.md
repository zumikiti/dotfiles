---
name: task-to-pr-loop
description: 指示されたタスク（文章・Jira URL/キー、複数可）ごとに wt でワークツリーとブランチを切り、実装サブエージェントに実装と create-pr での Draft PR 作成を任せ、PR ができたら tmux の別ウィンドウで pr-review-loop を回し、完了マーカーを見届けたら close-worktrees で後片付けするまでを指揮するパイプライン。「wt でブランチ切って実装して PR 作って PR loop 回して」「タスクを PR まで仕上げて後片付けまで」「worktree で実装→PR→レビューループ」「このチケット PR にしてレビューループまで回して」「これとこれを並列で PR にして loop して」「実装からレビュー修正、片付けまで全部やって」と言われたら、単発の create-pr や pr-review-loop ではなく必ずこちらを使う。Jira は読むだけで、遷移やコメントはしない（それは jira-epic-pipeline）。
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Skill
  - Agent
  - AskUserQuestion
  - Monitor
  - ToolSearch
  - mcp__claude_ai_Atlassian_Rovo__getJiraIssue
---

# task-to-pr-loop

タスク 1 件につき「ワークツリー 1 つ → 実装サブエージェント 1 体 → Draft PR 1 本 → loop ウィンドウ 1 つ」を作り、複数タスクは並列に流す。
このセッションは**指揮役**に徹し、コードは書かない。差分が小さく見えても実装はサブエージェントに渡す。指揮役が実装まで抱えると、並列タスクの待ち合わせ・後片付けの判断が埋もれ、loop 側との作業場所の取り合いも起きやすくなるためじゃ。

部品は既存スキルを使い、その中身をここで繰り返さない:

| 工程 | 使うもの |
|---|---|
| コミット / Draft PR | `commit` / `create-pr`（実装エージェントが Skill ツールで呼ぶ） |
| レビュー・修正・CI 見届け | `pr-review-loop`（別ウィンドウの別セッション） |
| 後片付け | `close-worktrees` の `close.sh` |
| サブエージェントのモデル | `subagent-model-policy` |

## 前提

- `wt` は worktrunk CLI。組み込みの EnterWorktree ではない
- loop は tmux の別ウィンドウで起動するので、このセッションが tmux 内（`$TMUX` が空でない）であること。tmux 外なら PR 作成で止め、ユーザーに手動起動の方法を伝える
- Jira は**読むだけ**。遷移・コメント・担当者変更はしない（ユーザーとの取り決め。Jira 更新まで要るなら `jira-epic-pipeline` を使う）
- サブエージェントの `model` は必ず明示する。`subagent_type: "fork"` は使わない（親のモデルを継承して割高になる）

## 手順

### 0. 入力の読解

- 入力をタスク単位に分ける（文章 / Jira URL / Jira キーが混在してよい）
- Jira は `ToolSearch` で `select:mcp__claude_ai_Atlassian_Rovo__getJiraIssue` を読み込み、cloudId `0d015b1f-6e94-4d5a-9738-aa0b39962c0e` で取得する。要件・受け入れ条件・スコープ外を抜き出す
- タスクごとにブランチ名を決める: Jira があれば `feature/<JIRAキー>-<slug>`、無ければ `feature/<slug>`。`create-pr` はブランチ名からチケット ID を拾うので、キーは必ず入れる
- 仕様が読み切れない・タスク間で同じファイルを大きく触りそうなときは、ここで一度だけユーザーに確認する

### 1. ワークツリー作成

ローカルの既定ブランチが古いまま切ると、何十コミットも遅れた土台で実装してしまう（実際に 35 コミット遅れていた）。メインのチェックアウトで次の順に行う:

```bash
git fetch origin --prune
git remote show origin | grep 'HEAD branch'            # 既定ブランチを確認（以下 <default>）
git -C <main repo> pull --ff-only origin <default>
wt switch --create feature/<slug> --base <default> --no-cd -y   # タスクの数だけ
git worktree list
git rev-parse origin/<default>                         # 全ワークツリーの SHA がこれと一致するか照合
```

- `--no-cd -y` は対話的な cd と承認を飛ばすため。worktree のパスは `<repo>.<ブランチ名の / を - に置換>`（例 `business-account-api.feature-GCK16-123-foo`）。推測で済ませず `git worktree list` の出力から取る
- 「Cannot change directory — shell requires restart」は無害
- SHA がずれたワークツリーは、作業開始前に限り `git -C <wt> reset --hard origin/<default>` で揃える

### 2. preflight: 無視ファイルの確認

`.gitignore` されたローカルファイルは新しいワークツリーに無い。`.npmrc`（GitHub Packages の認証）や `.env` が無いと `npm ci` が E401 で落ち、実装エージェントが止まる。しかも認証ファイルのコピーは auto mode の分類器に止められ Claude からは行えない。だから**エージェントを起動する前に**確認する:

```bash
git -C <main repo> ls-files --others --ignored --exclude-standard --directory \
  | grep -v '/' \
  | while read -r f; do [ -e "<wt>/$f" ] || echo "$f"; done
```

- `grep -v '/'` で直下のファイルだけに絞る（`node_modules/`・`.flox/`・`.claude/`・ビルド成果物ディレクトリは落ちる）
- 残った中から、ツールチェーンに必要なもの（`.npmrc`、`.env*`、`.tool-versions` 系のローカル設定など）を選ぶ。`.DS_Store` やログは無視
- 必要なものがあれば、ユーザーに `!` 付きで実行してもらう。全ワークツリー分を 1 行で渡し、**完了の返事を待ってから** 3. に進む:

```
! for w in <wt1> <wt2>; do cp -p <main repo>/.npmrc <main repo>/.env "$w"/; done
```

- 毎回の手間を消したい場合は、wt の post-create hook（`wt config` で設定）でコピーする手もあると一言添える。設定はしない

### 3. 実装サブエージェントの並列起動

タスクごとに 1 体、**1 メッセージで並列に**起動する。モデルは範囲が明確なら `sonnet`、判断を要するもの（DB 層に触るメジャーバージョンアップ等）は `opus`。

プロンプトの骨格（各タスクの値を埋める）。コミット末尾と PR 本文末尾の attribution 行は、このセッションの system-reminder（"Attribution for git commits and pull requests..."）が指定するものをそのまま転記して渡す。モデルによって変わるので固定で書かない。指定が無ければ付けない（例: PR 用は `🤖 Generated with [Claude Code](https://claude.com/claude-code)` のような行。あくまで例）:

```
作業ディレクトリ: <worktree 絶対パス>。この外は一切変更しない。
タスク: <要件・受け入れ条件・スコープ外。Jira があれば URL も>

ルール:
- .claude/ .flox/ node_modules/ はコミットしない。.npmrc やトークンの中身を表示しない
- 関連スキル（backend / frontend 等）があれば読んでから実装する
- 実際のツールチェーンを回す: 依存インストール → ビルド → lint → テスト。構文チェックだけでは不可。
  回せなかったものは捏造せず「未実行（理由）」と報告する
- Skill ツールで commit スキルを使い、意味単位でコミットする。
  コミット末尾: <system-reminder の Co-Authored-By 行>
- git push -u origin HEAD
- Skill ツールで create-pr スキルを args "<default>" で呼ぶ（base を渡すと確認待ちにならない）。
  Draft・--assignee @me・本文末尾に <system-reminder の PR 用の行>
- [並列時のみ] 他のエージェントが同時に動いている。docker compose の container_name・ホストのポート・
  共有テスト DB は取り合いになる。動いていれば再利用し、down / rm / リセットはしない

報告: PR URL / 実行したコマンドと結果（数値で） / 確認済みの事実と未確認事項を分けて
```

エージェントが走っている間、同じ調査を自分で重ねない。報告が届いたら PR 番号を控え、PR が無い・push されていないタスクは loop に進めず理由を最後に報告する。

### 4. loop の起動

実装エージェントの**完了報告を受け取ってから**起動する。同じワークツリーで実装と loop が同時に書き込むと壊れるため。

```bash
[ -n "$TMUX" ] || echo "tmux 外"                       # 外なら PR 段階で止める
tmux display-message -p '#S'                           # 現在のセッション名
tmux new-window -d -n pr-<N> -c <worktree> "claude --permission-mode auto '/pr-review-loop <N>'"
```

- ウィンドウの target `<session>:pr-<N>` を控える
- cwd をその PR のワークツリーにするのは、`pr-review-loop` が「カレントが PR のブランチ」を前提にしているから。同じブランチを他の場所でチェックアウトしない

### 5. 完了待ち

同梱スクリプトで完了マーカー `✅ pr-review-loop 完了 (PR #<N>)` を待つ。`📊 最終レビューレポート` は CI 見届けより前に出るので完了の目印にしない。

```bash
~/.claude/skills/task-to-pr-loop/scripts/wait-loop.sh <session>:pr-<N> <N> [max-minutes]
```

| 出力 / 終了コード | 意味 | 対応 |
|---|---|---|
| `[done]` / 0 | 完了マーカーを検出 | 6. へ |
| `[gone]` / 1 | ウィンドウが消えた（claude が落ちた・終了した） | 後片付けせず、ワークツリーの状態を確認して報告 |
| `[timeout]` / 2 | 既定 90 分で終わらない | ウィンドウを残したまま状況を報告 |
| `[heads-up]` 行 | 権限プロンプト等で 3 分以上止まっていそう | ユーザーに「ウィンドウ `<target>` で応答を」と知らせる。待機は続く |

- Monitor ツール（タイムアウトは長めに取り、切れたら張り直す）か `run_in_background` の Bash で走らせ、このセッションは他タスクの面倒を見続ける。複数 PR はスクリプトを PR ごとに走らせる

### 6. 回収と後片付け

1 PR ずつ、完了したものから行う。ウィンドウを消す前にログを取るのは、消すと最終レポートが読めなくなるから。

```bash
tmux capture-pane -p -t <target> -S - > <scratchpad>/pr-<N>-loop.log
# ログから 📊 最終レビューレポート 以降を抜き出す（総合評価・残指摘・CI 結果）
git -C <worktree> status --short
git -C <worktree> log @{u}..                        # 空であること
gh pr checks <N> --json name,bucket                 # CI の最終状態
tmux kill-window -t <target>
cd <main repo> && ~/.claude/skills/close-worktrees/close.sh --dry-run feature/<slug>
cd <main repo> && ~/.claude/skills/close-worktrees/close.sh feature/<slug>
```

- `close.sh` はブランチを既定で残す（PR が open なので消さない）
- `close.sh` が dirty / 未 push で拒否したら（終了 1）、`--force` は使わない。残っている変更・コミットを報告し、ワークツリーは残す。loop が push しきれなかった作業を消さないため

### 7. 報告

全タスクが 6. まで済んだら（または止まったら）まとめて報告する。

```
## task-to-pr-loop 結果

| タスク | PR | loop 評価 | CI | 後片付け |
|---|---|---|---|---|
| <タスク / Jira キー> | <URL> | 初回 X/10 → 最終 Y/10 | pass / fail（件名） | 済 / 残置（理由） |

### 残指摘（本 PR 外・未確認）
- PR #<N>: 🔴/🟡/🟢 <内容>

### 人の作業として残るもの
- stg での動作確認 / Draft 解除 / 人のレビュー依頼 / 未実行のテスト（理由）

### 確認できなかったこと
- <未確認事項。推測は推測と書く>
```

## 並列時の注意

- ワークツリー作成・preflight・ユーザーへのコピー依頼は全タスク分まとめて 1 回で済ませる
- 実装エージェントには共有資源（docker の固定コンテナ名・ポート・テスト DB）の注意を必ず入れる。片方の `docker compose down` で他方のテストが落ちる
- loop は PR ごとに別ウィンドウ、`wait-loop.sh` も PR ごと。後片付けは終わったものから順に行い、全部を待たない
- タスク同士が同じファイルを触る場合はコンフリクトが起きうるので、報告にその旨を書く（マージ順は人が決める）

## やってはいけないこと

- 指揮役が自分で実装・修正する（小さな差分でも委譲する）
- Jira への書き込み（遷移・コメント・担当者変更）
- 認証ファイルを Claude がコピーしようとする（分類器に止められる。ユーザーに `!` で頼む）
- 実装エージェントが動いている最中に loop を起動する
- `📊 最終レビューレポート` を見て完了とみなす
- `close.sh --force` や `--delete-branch` を使う
- ログを取る前に `tmux kill-window` する

## Gotchas

- `wt switch` を `--no-cd -y` なしで呼ぶと、cd や承認の対話で止まることがある
- `git worktree list` を見ずにパスを組み立てると、`/` → `-` の置換を誤る
- 実装エージェントが「テスト通過」と言っても、コマンドと数値が無ければ未確認として扱う
- loop ウィンドウの claude が `--permission-mode auto` でも、分類器が止めた操作は権限プロンプトで待つ。`[heads-up]` はそのためにある
- tmux の `base-index` 次第で `<session>:0` が存在しないことがある。target は番号でなくウィンドウ名 `pr-<N>` で指す
