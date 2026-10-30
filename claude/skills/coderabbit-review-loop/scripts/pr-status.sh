#!/usr/bin/env bash
# PR の「最終 head に対する」CI と CodeRabbit の状態を JSON で出す（読み取り専用）。
# 使い方: pr-status.sh <PR番号> [owner/repo]   （repo 省略時はカレントの gh リポジトリ）
set -euo pipefail

pr="${1:?usage: pr-status.sh <PR number> [owner/repo]}"
[[ $pr =~ ^[0-9]+$ ]] || { echo "PR number must be numeric" >&2; exit 1; }
repo_info=$(gh repo view ${2:+"$2"} --json nameWithOwner,defaultBranchRef)
repo=$(jq -r .nameWithOwner <<<"$repo_info")
default_branch=$(jq -r .defaultBranchRef.name <<<"$repo_info")
bot='coderabbitai[bot]'

view=$(gh pr view "$pr" -R "$repo" --json number,state,isDraft,baseRefName,headRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision)
sha=$(jq -r .headRefOid <<<"$view")
# 最終 head のコミット日時。committer date は push 時刻ではないので、承認の根拠には使わない
# （コメント時刻から「待機を抜けて再確認する」判断の目安にだけ使う）
head_committed_at=$(gh api "repos/$repo/commits/$sha" --jq .commit.committer.date)
# base が既定ブランチか・必須承認数は人のレビュー必須の判定に使う
base_branch=$(jq -r .baseRefName <<<"$view")
# base の必須承認数。rulesets（read 権限で取れる）と旧来のブランチ保護（admin 権限が必要・rulesets は反映されない）の最大値を使う。
# 旧保護は「Branch not protected」なら 0、それ以外の失敗は不明。両方取れなければ null（呼び出し側は止める側に倒す）
base_enc=$(jq -rn --arg b "$base_branch" '$b|@uri')
# rulesets の取得失敗は「ルールなし」と区別できないので、失敗したら legacy の結果にかかわらず null（不明）にする
if ! rules_n=$(gh api "repos/$repo/rules/branches/$base_enc" --jq '[.[] | select(.type=="pull_request") | .parameters.required_approving_review_count // 0] | max // 0' 2>/dev/null); then
  rules_n=""
  rules_failed=1
fi
if prot=$(gh api "repos/$repo/branches/$base_enc/protection" --jq '.required_pull_request_reviews.required_approving_review_count // 0' 2>&1); then
  prot_n=$prot
elif grep -q 'Branch not protected' <<<"$prot"; then
  prot_n=0
else
  prot_n=""
fi
if [[ -n ${rules_failed:-} ]]; then
  base_required_approvals=null
else
  base_required_approvals=$(jq -n --arg a "$rules_n" --arg b "$prot_n" '[$a,$b | select(test("^[0-9]+$")) | tonumber] | if length==0 then null else max end')
fi

# CI: コミット SHA 単位で取る（PR 単位の表示は push 直後に旧 head の結果を返すことがある）
checks=$(gh api --paginate "repos/$repo/commits/$sha/check-runs?per_page=100" --jq '.check_runs[] | {name, status, conclusion}' | jq -s .)
# 旧来のコミットステータスで報告する CI も verdict に含める
raw_status=$(gh api "repos/$repo/commits/$sha/status?per_page=100")
statuses=$(jq '[.statuses[] | {name: .context, status: (if .state=="pending" then "in_progress" else "completed" end), conclusion: (if .state=="success" then "success" elif .state=="pending" then null else "failure" end)}]' <<<"$raw_status")
checks=$(jq -s 'add' <<<"$checks$statuses")
# CodeRabbit が最終 head の SHA に付けたコミットステータス / check（コメント時刻に頼らず head への紐付けで判定できる）
cr_head=$(jq -c '[.[] | select(.name|test("coderabbit";"i")) | {name, status, conclusion}]' <<<"$checks")
# CI の verdict は CodeRabbit 自身のステータスを除く（レビュー待ちと CI 待ちを混ぜない）
ci_checks=$(jq -c '[.[] | select(.name|test("coderabbit";"i")|not)]' <<<"$checks")

# CodeRabbit のレビュー（どの commit に対するものか）
reviews=$(gh api --paginate "repos/$repo/pulls/$pr/reviews?per_page=100" \
  | jq -s --arg bot "$bot" '[.[][] | select(.user.login==$bot) | {state, commit_id, submitted_at}]')

# 直近の CodeRabbit の issue コメント（レート制限・進行中・完了の判定用に先頭 200 字だけ）
comments=$(gh api --paginate "repos/$repo/issues/$pr/comments?per_page=100" \
  | jq -s --arg bot "$bot" '[.[][] | select(.user.login==$bot) | {created_at, head: (.body | gsub("<!--[^>]*-->";"") | gsub("^\\s+";"") | .[0:200])}] | .[-3:]')

# 未解決のレビュースレッド数
owner=${repo%%/*}; name=${repo##*/}
unresolved=$(gh api graphql -f query='
query($o:String!,$n:String!,$p:Int!,$endCursor:String){repository(owner:$o,name:$n){pullRequest(number:$p){reviewThreads(first:100,after:$endCursor){pageInfo{hasNextPage endCursor} nodes{isResolved}}}}}' \
  -f o="$owner" -f n="$name" -F p="$pr" --paginate \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved|not)] | length' | jq -s 'add // 0')
unresolved=${unresolved:-0}

jq -n --argjson v "$view" --argjson c "$ci_checks" --argjson r "$reviews" --argjson k "$comments" --argjson u "$unresolved" --arg sha "$sha" --arg hca "$head_committed_at" --arg def "$default_branch" --argjson req "$base_required_approvals" --argjson crh "$cr_head" '
  ($r | map(select(.commit_id==$sha))) as $onhead
  | ($c|map(select(.status!="completed"))|length) as $pending
  | ($c|map(select(.status=="completed" and (.conclusion|IN("success","skipped","neutral")|not)))|length) as $failed
  | {
    pr: $v.number, state: $v.state, draft: $v.isDraft,
    base: $v.baseRefName, defaultBranch: $def, baseIsDefault: ($v.baseRefName==$def), head: $v.headRefName, headSha: $sha, headCommittedAt: $hca, baseRequiredApprovals: $req,
    mergeable: $v.mergeable, mergeStateStatus: $v.mergeStateStatus,
    reviewDecision: $v.reviewDecision,
    ci: {
      total: ($c|length),
      pending: $pending,
      failed: $failed,
      # 0 件は「緑」ではなく「未起動」（base と衝突中など）
      verdict: (if ($c|length)==0 then "not_started"
                elif $pending>0 then "pending"
                elif $failed>0 then "failed"
                else "success" end)
    },
    coderabbit: {
      reviewsOnHead: $onhead,
      checksOnHead: $crh,
      latestStateOnHead: ($onhead | last | .state // null),
      lastReviewedSha: ($r | last | .commit_id // null),
      recentComments: $k
    },
    unresolvedThreads: $u
  }'
