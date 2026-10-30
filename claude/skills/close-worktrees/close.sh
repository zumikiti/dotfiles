#!/usr/bin/env bash
# workmux / wt (worktrunk) 製のワークツリーを安全に閉じる driver。
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
usage: close.sh [--dry-run] [--delete-branch] [--force] <name>...
  name: workmux の handle、wt のブランチ名、またはワークツリーのパス
  --dry-run        何をするか表示するだけ
  --delete-branch  ブランチも削除する (既定は残す)
  --force          dirty / 未 push でも閉じる (既定は拒否)
USAGE
  exit 2
}

dry=0 delbranch=0 force=0
names=()
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;;
    --delete-branch) delbranch=1 ;;
    --force) force=1 ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $a" >&2; usage ;;
    *) names+=("$a") ;;
  esac
done
[ ${#names[@]} -gt 0 ] || usage

git rev-parse --show-toplevel >/dev/null
porcelain=$(git worktree list --porcelain)
# 1 件目が本体ワークツリー (閉じない)
main=$(printf '%s\n' "$porcelain" | awk '/^worktree /{sub(/^worktree /,""); print; exit}')

# 出力: path<TAB>branch  (本体を除く)
entries=$(printf '%s\n' "$porcelain" | awk -v RS= -F'\n' 'NR>1{p="";b="";for(i=1;i<=NF;i++){if($i~/^worktree /)p=substr($i,10);if($i~/^branch /)b=substr($i,8)}sub(/^refs\/heads\//,"",b);print p"\t"b}')

rc=0
removed=() removed_paths=() removed_branches=()
for name in "${names[@]}"; do
  path="" branch=""
  while IFS=$'\t' read -r p b; do
    [ -n "$p" ] || continue
    if [ "$name" = "$b" ] || [ "$name" = "$(basename "$p")" ] || [ "$name" = "$p" ]; then
      path=$p branch=$b; break
    fi
  done <<<"$entries"

  if [ -z "$path" ]; then
    echo "[skip] $name: 見つからない (本体ワークツリーは対象外)" >&2
    rc=1; continue
  fi

  case "$path" in
    */*__worktrees/*) kind=workmux ;;
    *) kind=wt ;;
  esac

  reasons=()
  # upstream に依存せず判定する (upstream なし / gone / detached / 操作途中でも見逃さない)
  if st=$(git -C "$path" status --porcelain --untracked-files=all 2>&1); then
    [ -z "$st" ] || reasons+=("未コミットの変更あり")
  else
    reasons+=("git status に失敗 (パス消失など)")
  fi
  if ! git -C "$path" symbolic-ref -q HEAD >/dev/null 2>&1; then
    reasons+=("detached HEAD")
  fi
  # どのリモート追跡ブランチにも含まれないコミットがあれば未 push
  if [ -n "$(git -C "$path" rev-list -n1 HEAD --not --remotes 2>/dev/null)" ]; then
    reasons+=("未 push のコミットあり (リモートに無い)")
  fi
  for f in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD BISECT_LOG; do
    gp=$(git -C "$path" rev-parse --git-path "$f" 2>/dev/null) || continue
    case "$gp" in /*) ;; *) gp="$path/$gp" ;; esac
    if [ -e "$gp" ]; then
      reasons+=("rebase / merge / cherry-pick / bisect の途中 ($f)"); break
    fi
  done
  if [ ${#reasons[@]} -gt 0 ]; then
    if [ $force -eq 1 ]; then
      echo "[warn] $name: ${reasons[*]} (--force で続行)"
    else
      echo "[skip] $name: ${reasons[*]} (閉じるなら --force)" >&2
      rc=1; continue
    fi
  fi

  if [ "$kind" = workmux ]; then
    # -f は確認プロンプトの省略 (dirty / 未 push は上のガードで判定済み)
    cmd=(workmux remove -f)
    [ $delbranch -eq 1 ] || cmd+=(-k)
    cmd+=("$(basename "$path")")
  else
    cmd=(wt remove --foreground)
    [ $delbranch -eq 1 ] || cmd+=(--no-delete-branch)
    [ $force -eq 1 ] && cmd+=(-f)
    cmd+=("${branch:-$path}")
  fi

  echo "[$kind] $name -> $path (branch: ${branch:-detached})"
  echo "  + (cd $main && ${cmd[*]})"
  if [ $dry -eq 0 ]; then
    (cd "$main" && "${cmd[@]}") || { echo "[fail] $name" >&2; rc=1; continue; }
    removed+=("$name") removed_paths+=("$path") removed_branches+=("$branch")
  fi
done

if [ $dry -eq 0 ] && [ ${#removed[@]} -gt 0 ]; then
  git -C "$main" worktree prune
  echo "--- git worktree list"
  git -C "$main" worktree list
  wl=$(git -C "$main" worktree list --porcelain)
  for i in "${!removed[@]}"; do
    # 解決済みのパス / ブランチで固定文字列の行一致を取る (name は正規表現にしない)
    if grep -qxF "worktree ${removed_paths[$i]}" <<<"$wl" || { [ -n "${removed_branches[$i]}" ] && grep -qxF "branch refs/heads/${removed_branches[$i]}" <<<"$wl"; }; then
      echo "[warn] ${removed[$i]} はまだ worktree list に残っている" >&2; rc=1
    fi
  done
fi
exit $rc
