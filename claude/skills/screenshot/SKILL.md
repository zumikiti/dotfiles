---
name: screenshot
description: 新規画面や修正した画面を Claude 自身が目で確認するとき、「画面を確認して」「スクショ撮って」等の依頼時、実装後の見た目の検証に使う。ログイン済み Cookie を注入して Web ページのスクリーンショットを撮る。
---

# screenshot

実行中の Web アプリ（ログイン必須でも可）のスクリーンショットを撮り、Read ツールで目視確認する。

## 前提

- dotfiles の flox 環境（manifest で宣言済み。chromium は Linux のみ、Mac は Google Chrome）を有効にして使う
- 初回のみ `~/.claude/skills/screenshot/scripts/` で `npm ci`（lock どおりに入れる。ブラウザはダウンロードされない）
- VM からホストの Docker へは `http://host.internal:<port>`

## 設定

`.screenshot.env` を カレントディレクトリ → git リポジトリ直下 の順で探す（git 管理外。無ければ先に対象アプリのリポジトリの `.gitignore`（または `~/.config/git/ignore`）へ追加してから作る）。

```
SCREENSHOT_BASE_URL=http://host.internal:8082
SCREENSHOT_COOKIE="name=PLACEHOLDER; name2=PLACEHOLDER"
```

- 同名の環境変数があればファイルより優先される
- `SCREENSHOT_CHROMIUM`（chromium のパス、任意）は環境変数のみ。ファイルからは読まない
- Cookie は `SCREENSHOT_BASE_URL` と同じホストにだけ送られる（別ホストの URL を渡しても注入されない）
- Cookie はユーザーがホストのブラウザでログイン後、DevTools の Network → 該当リクエストの Request Headers → `Cookie` をそのままコピーして貼る
- **Claude はこのファイルを絶対に cat/Read しない。値をコマンドに書かない。コミットしない**（認証情報）
- ファイルの作成・更新はユーザーに `!` プレフィックスのコマンドかエディタで行ってもらう
- 公開ページなら Cookie 無しでも動く

## 手順

1. 実行する
   ```
   node ~/.claude/skills/screenshot/scripts/shot.cjs <path-or-url> <out.png> [--full] [--width N] [--height N] [--wait MS]
   ```
   - `/` 始まりは `SCREENSHOT_BASE_URL` に連結される。既定 1440x900、`--full` で全体、`--wait` は networkidle 後の追加待ち(ms)
   - 出力先はセッションの scratchpad ディレクトリ（system prompt に記載があればそれ、無ければ `/tmp/screenshots/`）
2. 出力 1 行目の `final=` と `title=` で目的のページかを確かめる。同じホストのログイン画面（Laravel の `/login` など）へ飛んだ場合は終了コード 0 のままなので、ここで気づく
3. 出力 PNG を Read ツールで開いて目視する
4. 結果（表示崩れ、console error、pageerror、requestfailed）を報告する

## 終了コード

- 0: 成功
- 1: 引数誤り・URL 不正・接続失敗やタイムアウト。常時ポーリングのページは networkidle に達せず 30 秒で 1 になる
- 2: 別ホストへリダイレクトされた（SSO ログイン画面など）。Cookie 切れとしてユーザーに貼り直しを依頼する
- 3: chromium / playwright-core が無い、またはパス指定なのに `SCREENSHOT_BASE_URL` が無い（メッセージに従う）

## 補足

Cookie の寿命はアプリ依存。Laravel の remember Cookie は約30日、セッション Cookie は約2時間で切れる。
