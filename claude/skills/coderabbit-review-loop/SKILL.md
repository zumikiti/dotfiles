---
name: coderabbit-review-loop
description: PR を CodeRabbit（コードうさぎ）にレビューさせ、指摘を直して再依頼し、最終 head での APPROVED と CI 成功を確認してマージするまでを回す（base が main など既定ブランチの PR は人のレビュー必須のため、CodeRabbit 承認と CI 成功で止めて人に依頼する）。「コードうさぎにレビューしてもらって」「CodeRabbit の指摘を直して」「coderabbit の approve まで」「レビュー依頼して直してマージ」「積み上げ PR を順にマージ」と言われたら必ず使う。対象は CodeRabbit とのやり取り・approve 待ち・マージであり、サブエージェントによる内部レビューではない（それは pr-review-loop）。
---

# CodeRabbit レビュー・修正・マージループ

PR 1 本（または積み上げ PR の列を下から順に）を、CodeRabbit のレビュー → 指摘対応 → 再依頼 → approve → マージ → 次の PR、まで面倒を見る。
このスキルの起動が、統合ブランチ向け PR のマージの許可になる（都度の確認はしない）。base がデフォルトブランチ（main 等）の PR だけは、AI のレビューで本番に近いブランチへ入れないため、人のレビュー（approve）が必須で、マージせず止める。
内部レビューは行わない（関連: `pr-review-loop`。CodeRabbit の回数上限に備えて事前に潰したいときだけ、別途そちらを使う）。

## 使用方法

```
/coderabbit-review-loop <PR番号 | 範囲 | 列>    # 例: 123 / 123-130 / 123,124,127
```

`$ARGUMENTS` が複数 PR なら積み上げ PR として下から順（前の PR のマージ後に次へ）に処理する。無ければ PR 番号を尋ねる。

## 事実として押さえておくこと（観測済み）

- base がデフォルトブランチでない PR（積み上げの途中など）は CodeRabbit が自動レビューしない。
- 修正を push しても自動では再レビューされない。毎回 `@coderabbitai review` を明示投稿する。
- レビュー依頼には回数上限（時間あたり）がある。投稿は 1 head につき 1 回だけ。二重投稿は枠の浪費になる。
- 上限に当たるとレビューされず、その旨の返信が付く。約 15 分あけて再投稿する。
- 新しいコミットが無い head に再依頼すると「Already reviewed the last commit」（Action not completed）と返る。増分レビューなので、push が無ければ再依頼は無駄になる（全体を見直させたいときだけ `@coderabbitai full review`）。
- `gh pr checks` / `reviewDecision` は直後に旧 head の結果を返したり、古い head の APPROVED を引き継いだりする。判定は必ず最終 head の SHA で行う。
- base と衝突している PR は CI が起動しない。チェック 0 件は「緑」ではなく「未起動」。

## 補助スクリプト

`scripts/pr-status.sh <PR> [owner/repo]`（読み取り専用）。最終 head の SHA に対する CI と CodeRabbit の状態を JSON で出す。

- `ci.verdict`: `success` / `pending` / `failed` / `not_started`（0 件。衝突などで未起動）
- `coderabbit.latestStateOnHead`: 最終 head に対する CodeRabbit の最新レビュー状態（`APPROVED` / `CHANGES_REQUESTED` / `COMMENTED` / null）。null なら最終 head は未レビュー
- `coderabbit.recentComments`: CodeRabbit の直近コメント冒頭（レート制限・進行中の判別用）
- `reviewDecision`: 古い head の APPROVED を引き継ぐことがあるので、承認の根拠には `latestStateOnHead` を使う
- `baseIsDefault` / `defaultBranch`: base がデフォルトブランチか。true なら手順 8 は人のレビュー待ちで止める
- `unresolvedThreads`, `mergeable`, `mergeStateStatus`, `headSha`

## 手順（PR 1 本あたり）

### 1. 状態確認

1. `git fetch origin --prune` し、`gh pr view <N> --json baseRefName,headRefName,isDraft,state,mergeable` を見る。
2. base が、マージ済みで削除された直前ブランチのままなら、`gh pr edit <N> --base <本来の base>` で付け替える。
3. 作業ツリーは PR 専用のワークツリーを使う。ローカルブランチが origin と一致するか確認し、ずれていれば origin の先頭に切り替えてから作業する（古いローカル版へ push しない）。

### 2. 積み上げ PR のとき: own commits だけを載せ直す

積み上げでは、直前 PR のレビュー修正やリベースで親が変わる。素の `git rebase` だと古い親のコミットが混ざる。

- own commits（この PR だけのコミット）を特定する。`gh pr view <N> --json commits`、または base が直前 PR ブランチを指している間の `git log origin/<base>..origin/<head>`。マージして base が変わる前に、次の PR の own commits を進捗ログへ記録しておく。
- 直前 PR がマージコミットでそのまま入ったなら載せ直し不要。`git merge-base --is-ancestor <直前 PR の head> origin/<base>` と、`git log origin/<base>..origin/<head>` が own commits だけであることを確認して次へ進む。
- 直前 PR にレビュー修正が積まれていた場合のみ `git rebase --onto origin/<base> <own commits の最初の親>` で載せ直す。merge コミットが混ざっているなら cherry-pick で own commits を順に載せる。
- 載せ直し後は `git diff origin/<base>...HEAD --stat` が意図したファイルだけか確認し、後述「検証」を通してから `git push --force-with-lease`（この載せ直し由来の force push のみ。レビュー修正は通常 push）。
- 共有部品（基底クラス、共通ヘルパ、改名したクラスなど）が直前 PR で変わっていたら、この PR のコードを追従させ、テストを通して CI を確認する。

### 3. Ready 化と初回依頼

1. Draft なら `gh pr ready <N>`。
2. `gh pr comment <N> --body "@coderabbitai review"` を 1 回だけ投稿する。自動レビューが走る PR（base がデフォルトブランチ）では、先に `scripts/pr-status.sh` で CodeRabbit の動き（進行中コメント）を確認し、動いていれば投稿しない。

### 4. 待機

- Monitor か `run_in_background` の until ループ（60 秒間隔で `scripts/pr-status.sh` を呼ぶ）で待つ。foreground の sleep は使えない。
- 待つ条件は「`ci.verdict` が `pending` でない」かつ「CodeRabbit が最終 head にレビューを返した（`latestStateOnHead` が null でない、またはレート制限コメント）」。
- `ci.verdict` が `not_started` なら、衝突や権限など CI が走らない原因を調べる（`mergeable` が `CONFLICTING` なら base とのコンフリクト解消が先）。
- 待機中に同じ調査を重ねない。

### 5. 指摘の仕分けと対応

CodeRabbit の指摘は `gh api repos/<repo>/pulls/<N>/comments`（インライン）と `gh pr view <N> --json reviews`（本文・nitpick）の両方で読む。actionable だけでなく nitpick も見る。

| 区分 | 対応 |
|---|---|
| 妥当 | 修正する。push 前に検証（下記）を実際に走らせる |
| 不採用 | 該当スレッドに日本語で根拠を返信する。根拠なしの却下はしない。例: 積み上げ途中で、後続 PR の画面を案内する文言への指摘 |
| スコープ外 | コードは直さず、PR 本文か最終報告に書く。後続 PR で入る内容は「後続 PR で対応」と返信 |
| 設計判断が要る | 勝手に決めず、止めてユーザーに渡す |

- 修正は小さな論理単位でコミットし、通常 push する（`commit` スキルに従う）。
- CI 失敗は本 PR 起因か切り分ける。無関係なフレークは `gh run rerun <run-id> --failed`。
- 指摘のうち、リポジトリ全般のガイドラインとして残す価値があるもの（層の責務、テストの流儀、UI の作法など）は、ガイド文書を直す PR があれば追記候補として集める。任意で、無理に追記しない。

### 6. 再依頼は 1 回だけ

修正 push、または不採用の返信をまとめて終えた後に、`@coderabbitai review` を 1 回投稿する。複数回の push を挟むなら、最後の push の後に 1 回だけ。同じ head への二重投稿をしない。
レート制限なら約 15 分あけて再投稿し、それでも駄目なら再び 15 分あける。手順 4 に戻る。修正ループは最大 5 回。超えたら止めて報告する。

### 7. 承認の確認

次のいずれかを満たして初めて「承認済み」とする。

- `latestStateOnHead` が `APPROVED`（最終 head に対する承認）
- 最終 head への「Review finished」系のコメントで指摘 0 件、かつ `unresolvedThreads` が 0

`reviewDecision` が `APPROVED` でも `latestStateOnHead` が null なら古い head の承認の引き継ぎ。その場合は「古い head の承認を引き継いでいるだけ」と区別して報告し、承認扱いにしない。
指摘が尽きても approve されないときは、過去の PR で何をして approve されたか（未解決スレッドの resolve、`@coderabbitai` コマンドなど）をコメント履歴で調べ、推測で済ませない。

### 8. マージと次の PR へ

1. `baseIsDefault` が true（base がデフォルトブランチ。`gh repo view --json defaultBranchRef` でも確認できる）なら、マージしない。CodeRabbit の承認と CI 成功まで済ませたら「人のレビュー待ち」として止め、報告で人のレビューを依頼する。人の approve が既にあってもマージの可否はユーザーとブランチ保護の方針に従い、迷ったら止める。積み上げ列の最後が main 向けなら、そこで列を終える。
2. 統合ブランチ向け（`baseIsDefault` が false）は、`ci.verdict` が `success`、承認済み（最終 head）、`mergeable` が `MERGEABLE` を確認でき次第、ユーザーへの確認なしにマージする。
3. マージ方式はリポジトリの慣例を確認する（`gh pr list --state merged` のマージコミットの形、CLAUDE.md、ブランチ保護）。積み上げではマージコミットにする（後続ブランチがそのまま乗り、own commits が崩れないため）。
4. `gh pr merge <N> --merge`（慣例に合わせて変える）。実行環境の権限設定が優先する。auto mode などで拒否されたら回避せず、状態を整理してユーザーに渡す。
5. 積み上げなら、次の PR の base が付け替わったか `gh pr view <N+1> --json baseRefName` で確認し、されていなければ付け替える。次の PR の own commits を記録し、その PR の手順 1 へ進む。

## 検証（コード変更を push する前に）

テスト・型チェック・lint を実際に走らせる。コマンドはリポジトリの CLAUDE.md を見る。構文チェックだけでは不可。ローカルで回せなかったものは、その事実を報告して CI で代替する。

## 止めて報告する条件

- 設計判断が要る指摘（仕様解釈が割れる、複数 PR にまたがる大きな変更）
- 修正ループ上限超過、本 PR 起因でない CI 失敗が直らない、マージ不可（コンフリクト・権限）
- PR が既にクローズ、base が想定と違うなど想定外の状態
- base がデフォルトブランチの PR で、CodeRabbit 承認と CI 成功まで済んだとき（人のレビュー待ち。マージしない）

## 複数 PR の運用（コーディネーターがいる場合）

親セッションは 1 PR ずつサブエージェントに任せる。進捗ログ（scratchpad のファイル）に、PR 番号・やったこと・未解決事項・次 PR の own commits を追記させ、手順の追加事項は手順書に書いて申し送る。サブエージェントの `model` は `subagent-model-policy` に従って明示する。

## 報告形式（簡潔に、日本語）

- PR 番号 / 結果（マージ済み、停止理由、または「人のレビュー待ち」。main 向けは人のレビューを依頼する旨を明記）
- 最終 head の SHA、承認の根拠（`APPROVED` が最終 head のものか、古い head の引き継ぎか）、CI の結果
- CodeRabbit の指摘と対処（採用・不採用と理由、スコープ外）
- 追加コミット一覧と検証の実施状況
- 次 PR への申し送り（衝突しそうな箇所、own commits）

## やってはいけないこと

- base がデフォルトブランチの PR を、CodeRabbit の承認だけでマージする（人のレビュー必須）
- 同じ head に `@coderabbitai review` を 2 回投稿する（枠を浪費する）
- push 直後の `gh pr checks` や `reviewDecision` をそのまま信じる（旧 head の結果の可能性）
- チェック 0 件・衝突中を CI 成功と扱う
- 先回りの内部レビューで base を PR ブランチへ merge する（own commits の特定が崩れる）
- 指摘を根拠なく却下する、マージ拒否を回避して強行する
