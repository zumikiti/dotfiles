#!/usr/bin/env bash
# tmux ウィンドウで動く pr-review-loop の完了マーカーを待つ。
#   exit 0: 「✅ pr-review-loop 完了 (PR #<N>)」を検出
#   exit 1: ウィンドウが消えた (claude が落ちた / 終了した)
#   exit 2: タイムアウト
# 入力待ち (権限プロンプト・質問) が続くと「[heads-up]」行を出す。Monitor で拾うため。
# 環境変数 WAIT_LOOP_INTERVAL (秒, 既定 30) / WAIT_LOOP_STUCK_SEC (秒, 既定 180) で間隔を変えられる (主にテスト用)。
set -u

usage() {
  echo "usage: wait-loop.sh <window-target> <PR番号> [max-minutes(既定 90)]" >&2
  echo "  例: wait-loop.sh work:pr-123 123 120" >&2
  exit 64
}
[ $# -ge 2 ] || usage

target=$1 pr=$2 max_min=${3:-90}
interval=${WAIT_LOOP_INTERVAL:-30}
stuck_after=${WAIT_LOOP_STUCK_SEC:-180}   # 入力待ちがこの秒数続いたら知らせる
marker="✅ pr-review-loop 完了 (PR #${pr})"
# 権限プロンプト・選択肢待ちの目印。画面末尾だけを見る (過去ログの誤検知を避ける)
prompt_re='Do you want to|Allow|Yes, and don.t ask|❯ 1\.|Esc to cancel'

start=$(date +%s)
waiting_since=""
notified=0

while :; do
  if ! tmux list-panes -t "$target" >/dev/null 2>&1; then
    echo "[gone] ウィンドウ $target が見つからない (claude が終了した可能性)"
    exit 1
  fi

  pane=$(tmux capture-pane -p -t "$target" -S -400 2>/dev/null || true)
  if printf '%s\n' "$pane" | grep -qF -- "$marker"; then
    echo "[done] $marker を検出"
    exit 0
  fi

  now=$(date +%s)
  if printf '%s\n' "$pane" | grep -v '^[[:space:]]*$' | tail -n 15 | grep -qE -- "$prompt_re"; then
    [ -n "$waiting_since" ] || waiting_since=$now
    if [ $notified -eq 0 ] && [ $((now - waiting_since)) -ge $stuck_after ]; then
      echo "[heads-up] $target が ${stuck_after} 秒以上入力待ちの可能性。ウィンドウで権限プロンプトに答えてください"
      notified=1
    fi
  else
    waiting_since="" notified=0
  fi

  if [ $((now - start)) -ge $((max_min * 60)) ]; then
    echo "[timeout] ${max_min} 分経っても完了マーカーが出ない ($target)"
    exit 2
  fi
  sleep "$interval"
done
