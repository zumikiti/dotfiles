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
removed=()
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
  if [ -n "$(git -C "$path" status --porcelain)" ]; then
    reasons+=("未コミットの変更あり")
  fi
  if git -C "$path" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    if [ -n "$(git -C "$path" log '@{u}..HEAD' --oneline)" ]; then
      reasons+=("未 push のコミットあり")
    fi
  fi
  if [ ${#reasons[@]} -gt 0 ]; then
    if [ $force -eq 1 ]; then
      echo "[warn] $name: ${reasons[*]} (--force で続行)"
    else
      echo "[skip] $name: ${reasons[*]} (閉じるなら --force)" >&2
      rc=1; continue
    fi
  fi

  if [ "$kind" = workmux ]; then
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
    removed+=("$name")
  fi
done

if [ $dry -eq 0 ] && [ ${#removed[@]} -gt 0 ]; then
  git -C "$main" worktree prune
  echo "--- git worktree list"
  git -C "$main" worktree list
  for name in ${removed[@]+"${removed[@]}"}; do
    if git -C "$main" worktree list --porcelain | grep -qE "^(worktree .*[/]${name}$|branch refs/heads/${name}$)"; then
      echo "[warn] $name はまだ worktree list に残っている" >&2; rc=1
    fi
  done
fi
exit $rc
