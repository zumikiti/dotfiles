#!/usr/bin/env bash
# tmux ウィンドウで動く pr-review-loop の完了マーカーを待つ。
#   exit 0: 「✅ pr-review-loop 完了 (PR #<N>)」を検出
#   exit 1: ウィンドウが消えた (claude が落ちた / 終了した)
#   exit 2: タイムアウト
#   exit 3: 「⛔ pr-review-loop 中断 (PR #<N>)」を検出 (loop 側が中断した)
#   exit 64: 引数・環境変数の不正 / exit 65: tmux が無い
# 入力待ち (権限プロンプト・質問) が続くと「[heads-up]」行を出す。Monitor で拾うため。
# 環境変数 WAIT_LOOP_INTERVAL (秒, 既定 30) / WAIT_LOOP_STUCK_SEC (秒, 既定 180) で間隔を変えられる (主にテスト用)。
# deliberate: pipefail は付けない。grep -q が早期終了すると上流が SIGPIPE で落ち、一致しても失敗扱いになるため
set -u

usage() {
  echo "usage: wait-loop.sh <window-target> <PR番号> [max-minutes(既定 90)]" >&2
  echo "  target: ウィンドウ ID (@N, 推奨) / <session>:<window名> (完全一致で解決) / pane 指定" >&2
  echo "  例: wait-loop.sh @5 123 120" >&2
  exit 64
}
[ $# -ge 2 ] || usage

target=$1 pr=$2 max_min=${3:-90}
interval=${WAIT_LOOP_INTERVAL:-30}
stuck_after=${WAIT_LOOP_STUCK_SEC:-180}   # 入力待ちがこの秒数続いたら知らせる
# 算術展開 $((…)) に未検証の値が入るとコマンドが走るため、先に正の整数か確かめる (08 は 8 進数エラー、0 は待ちなしループになる)
for v in "$pr" "$max_min" "$interval" "$stuck_after"; do
  [[ $v =~ ^[1-9][0-9]*$ ]] || { echo "[error] 数値でない引数/環境変数がある" >&2; usage; }
done
command -v tmux >/dev/null 2>&1 || { echo "[error] tmux が見つからない" >&2; exit 65; }

# tmux はウィンドウ名を前方一致で解決する (pr-12 で pr-123 に当たる)。<session>:<名前> は = で完全一致にする
case "$target" in
  *.*|%*|@*) ;;
  *:=*) ;;
  *:*) target="${target%%:*}:=${target#*:}" ;;
esac
marker="✅ pr-review-loop 完了 (PR #${pr})"
abort_marker="⛔ pr-review-loop 中断 (PR #${pr})"
# 権限プロンプト・選択肢待ちの目印。画面末尾だけを見る (過去ログの誤検知を避ける)
prompt_re='Do you want to|Yes, and don.t ask|❯ 1\.|Esc to cancel'

# pane 指定 (session:window.pane / %id) ならそのまま、ウィンドウ指定なら全 pane を読む。
# ウィンドウ指定だと tmux はアクティブ pane だけ返す。workmux 等のサイドバー pane が
# アクティブになると claude の出力を見逃すため、pane を列挙して連結する。
list_panes() {
  case "$target" in
    *.*|%*) printf '%s\n' "$target" ;;
    *) tmux list-panes -t "$target" -F '#{pane_id}' 2>/dev/null ;;
  esac
}

start=$(date +%s)
waiting_since=""
notified=0

while :; do
  if ! tmux list-panes -t "$target" >/dev/null 2>&1; then
    echo "[gone] ウィンドウ $target が見つからない (claude が終了した可能性)"
    exit 1
  fi

  tails=""
  while IFS= read -r pane_id; do
    [ -n "$pane_id" ] || continue
    # -J で折り返しを結合。マーカーも入力待ちも pane ごとの末尾 15 行だけを見る
    # (本文での言及や過去ログの誤検知を避け、サイドバーの文字で隠さない)
    text=$(tmux capture-pane -p -J -t "$pane_id" -S -400 2>/dev/null || true)
    tails+=$(printf '%s\n' "$text" | grep -v '^[[:space:]]*$' | tail -n 15)$'\n'
  done < <(list_panes)
  # マーカーは「行全体が一致」(前後空白のみ許容)。完了/中断は最終メッセージの最終行で出る。
  # Claude Code はアシスタント文の 1 行目に「● 」(環境により「⏺ 」) を付けて描画するので、先頭のそれも除く
  trimmed=$(printf '%s\n' "$tails" | sed -E 's/^[[:space:]]*((●|⏺)[[:space:]]+)?//; s/[[:space:]]*$//')
  if printf '%s\n' "$trimmed" | grep -qxF -- "$marker"; then
    echo "[done] $marker を検出"
    exit 0
  fi
  if printf '%s\n' "$trimmed" | grep -qxF -- "$abort_marker"; then
    echo "[aborted] $abort_marker を検出 (loop が中断した)"
    exit 3
  fi

  now=$(date +%s)
  if printf '%s\n' "$tails" | grep -qE -- "$prompt_re"; then
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
