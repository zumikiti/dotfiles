#!/usr/bin/env bash
# PR の「最終 head に対する」CI と CodeRabbit の状態を JSON で出す（読み取り専用）。
# 使い方: pr-status.sh <PR番号> [owner/repo]   （repo 省略時はカレントの gh リポジトリ）
set -euo pipefail

pr="${1:?usage: pr-status.sh <PR number> [owner/repo]}"
[[ $pr =~ ^[0-9]+$ ]] || { echo "PR number must be numeric" >&2; exit 1; }
repo="${2:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
bot='coderabbitai[bot]'

view=$(gh pr view "$pr" -R "$repo" --json number,state,isDraft,baseRefName,headRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision)
sha=$(jq -r .headRefOid <<<"$view")
# main 向けは人のレビュー必須の判定に使う
default_branch=$(gh repo view "$repo" --json defaultBranchRef -q .defaultBranchRef.name)

# CI: コミット SHA 単位で取る（PR 単位の表示は push 直後に旧 head の結果を返すことがある）
checks=$(gh api --paginate "repos/$repo/commits/$sha/check-runs?per_page=100" --jq '.check_runs[] | {name, status, conclusion}' | jq -s .)
# 旧来のコミットステータスで報告する CI も verdict に含める
statuses=$(gh api "repos/$repo/commits/$sha/status?per_page=100" --jq '[.statuses[] | {name: .context, status: (if .state=="pending" then "in_progress" else "completed" end), conclusion: (if .state=="success" then "success" elif .state=="pending" then null else "failure" end)}]')
checks=$(jq -s 'add' <<<"$checks$statuses")

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
  -F o="$owner" -F n="$name" -F p="$pr" --paginate \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved|not)] | length' | jq -s add)
unresolved=${unresolved:-0}

jq -n --argjson v "$view" --argjson c "$checks" --argjson r "$reviews" --argjson k "$comments" --argjson u "$unresolved" --arg sha "$sha" --arg def "$default_branch" '
  ($r | map(select(.commit_id==$sha))) as $onhead
  | ($c|map(select(.status!="completed"))|length) as $pending
  | ($c|map(select(.status=="completed" and (.conclusion|IN("success","skipped","neutral")|not)))|length) as $failed
  | {
    pr: $v.number, state: $v.state, draft: $v.isDraft,
    base: $v.baseRefName, defaultBranch: $def, baseIsDefault: ($v.baseRefName==$def), head: $v.headRefName, headSha: $sha,
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
      latestStateOnHead: ($onhead | last | .state // null),
      lastReviewedSha: ($r | last | .commit_id // null),
      recentComments: $k
    },
    unresolvedThreads: $u
  }'
