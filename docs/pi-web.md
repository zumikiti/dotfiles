# pi-web チートシート

pi coding agent（`/home/akihiro/.local/lib/node_modules/@earendil-works/pi-coding-agent`）の Web UI を、OrbStack の Linux ゲスト（flox-test）で動かしっぱなしにして、Mac のブラウザから監視するためのメモ。2026-08-30 に一から組み立てた経緯を、再開用として残す。

## 今なにがどこにあり、どう繋がっているか

```
Mac（ブラウザ）
   │  http://192.168.139.229:8504   ← OrbStack のプライベート IP（eth0）
   ▼
OrbStack guest "flox-test" (Linux, aarch64)
   ├─ pi-web.service      → Web UI + API   （8504 ポート、0.0.0.0 で listen）
   └─ pi-web-sessiond.service → session デーモン（pi を spawn、セッションを維持）
         └─ 起動: /bin/bash -lc "exec node .../dist/server/sessiond.js"
                環境変数 OXLM_API_KEY を unit に埋め込んでいる（下記「注意点」参照）

pi-web の本体（コード・bin）:
  /home/akihiro/.pi/agent/npm/node_modules/@jmfederico/pi-web
  （`pi install npm:@jmfederico/pi-web` が置いたもの）

pi-coding-agent（systemd サービスの PATH に載らないので、
  pi-web の隣に symlink を置いている）:
  /home/akihiro/.local/lib/node_modules/@earendil-works/pi-coding-agent
  /home/akihiro/.pi/agent/npm/node_modules/@earendil-works/{pi-coding-agent,pi-ai,pi-client,pi-protocol}
    すべて上の本来の場所への symlink（*.package.json は実ファイル）

systemd ユーザー unit（pi-web が生成、一部は自前編集済み）:
  ~/.config/systemd/user/pi-web.service
  ~/.config/systemd/user/pi-web-sessiond.service

設定:
  ~/.config/pi-web/config.json
    { "host": "0.0.0.0", "port": 8504, ... }
```

要するに、**systemd のユーザーサービスが 2 つ常駐して動いている**だけ。

## コマンド（日常で使う）

`pi-web` コマンド自体は PATH に無いので、フルパス付きで叩く。短縮する場合は alias を自分の shell 定義に足すと楽：

```bash
alias pi-web='node /home/akihiro/.pi/agent/npm/node_modules/@jmfederico/pi-web/dist/cli.js'
```

その上での基本操作：

```bash
pi-web status      # 両サービスが起動しているか（✓ / ✗）
pi-web logs        # systemd のログ表示
pi-web doctor      # 状態の総合診断（node の version、PATH、サービス）
pi-web restart     # 両サービスを再起動
```

ブラウザ: `http://192.0.0.1` の替わりに **`http://<guestのeth0 IP>:8504`**（執筆時 192.168.139.229）を開く。

## 明日以降の起動手順

サービスを既にインストール済みなら、**何もやらずに電源が管理する systemd が勝手に起動してくれる**（`enabled` 済み）。guest を立ち上げるだけで OK。

万一生きてないとき：

```bash
systemctl --user restart pi-web-sessiond.service pi-web.service
pi-web status
```

`✗ ... activating (auto-restart)` が続く＝起動即クラッシュのループ。このときは `journalctl --user -u pi-web-sessiond.service --no-pager | tail` で実エラーを見る。

## よくある症状と対処

### ブラウザが接続できない（Mac 側で page を開けない）
- guest の IP が変わっている可能性がある。guest 側で `ip -4 addr | grep eth0` を確認して URL を差し替える
- サービスが死んでいる → 上の「起動手順」を実施
- guest 内に curl で `curl -sS http://<IP>:8504/api/pi-web/version` が通るのにブラウザだけダメ → Mac のファイアウォール / VPN を疑う

### OXLM（omlx）のモデルが選べない
- 原因はほぼ `pi-web-sessiond` のプロセスに `OXLM_API_KEY` が無いこと。unit に
  `[Service]` セクション内に `Environment="OXLM_API_KEY=..."` を書いている。
  **unit の `[Install]` セクションの下（ファイル末尾）に足すと systemd が
  "Unknown key 'Environment' in section [Install], ignoring" と無視する**のが落とし穴。
- key を轮换（rotate）した場合: 両 unit の `Environment=` を更新 →
  `systemctl --user daemon-reload && systemctl --user restart pi-web-sessiond.service pi-web.service`
  → ブラウザを reload

### `Cannot find package '@earendil-works/...'`（起動即クラッシュ）
- pi-web の dist は `@earendil-works/*` を import するが、それらは
  `~/.pi/agent/npm/node_modules/@earendil-works/` に無いと解決されない。
 上の「構成」のブロックに書いた symlink が失われている（`pi install` の再実行で
  node_modules が作り直される等）なら、作り直す：

```bash
mkdir -p ~/.pi/agent/npm/node_modules/@earendil-works
BASE=~/.local/lib/node_modules/@earendil-works/pi-coding-agent
for p in pi-coding-agent pi-ai pi-client pi-protocol; do
  ln -sfn "$BASE/node_modules/@earendil-works/$p" \
           ~/.pi/agent/npm/node_modules/@earendil-works/$p 2>/dev/null \
  || ln -sfn "$BASE" ~/.pi/agent/npm/node_modules/@earendil-works/$p
done
systemctl --user restart pi-web-sessiond.service pi-web.service
```

### node が見つからない（`node >= 22.19 ... not available to the service shell`）
- systemd ユーザーサービスは `bash -lc` で起動する。login（shell） なので
  `~/.profile` を読む。そこに flox の node が通る PATH ブロックを置いている：

```
# >>> pi-web node bridge (managed) >>>   （~/.profile 内）
if [ -z "$FLOX_ENV" ] && [ ! -t 0 ]; then
  if [ -d "$HOME/dotfiles/.flox/run/aarch64-linux.dotfiles.dev/bin" ]; then
    PATH="$HOME/dotfiles/.flox/run/aarch64-linux.dotfiles.dev/bin:$PATH"
    export PATH
  fi
fi
# <<< pi-web node bridge <<<
```

- 注意：`$HOME/dotfiles/.flox/run/aarch64-linux.dotfiles.dev/bin` は
  **floX が作った一時的な store パス**。`flox update` で node のバージョンが変わると
  このパスは消える／変わるので、そのたびにこのブロックのパスを書き換え →
  `systemctl --user restart pi-web-*`。一時的な解決だが、堅い代わりに
  「明日 node がなくなってるかも」は頭に入れておく。

## 知っておくと助かる仕組み（深い説明不要、意味だけ）

- pi-web は「**サービスとして常駐させるための薄い Web サーバ + session デーモン**」で、
  ブラウザを閉じてもセッションは guest 内で生き続ける。再起動のたび毎回 session を
  復元させるのが目的。
- 両サービスは **systemd ユーザ（`systemctl --user`）** で動いている。
  `pi-web start / stop / restart / status / logs` の背後は全部 systemd。
- `~/.config/pi-web/config.json` の `"host": "0.0.0.0"` があるから、guest の
  **どのインターフェースからも**到達できる（OrbStack の bridge や docker
  ネットワーク含む）。公開の network に吐きたくない場合は `"host"` を特定 IP
  （例 `"192.168.139.229"`）に変えると安全。
- 上記の `Environment=...`（OXLM key）は **平文** で unit にある。このファイルが
  他人に見られる（`~/.config/systemd/user/`）環境なら、`EnvironmentFile=` +
  `chmod 600 ~/.pi-web.env` の方が清潔。今ここはローカル専用なので平文で運用。

## もし全部やめて売り払いたくなったら（完全削除）

```bash
# 1. サービスを停める＆アンインストール
pi-web uninstall
# 2. 残骸（symlink と unit、設定）を消す
rm -rf ~/.pi/agent/npm/node_modules/@earendil-works   # 後述: symlink の dir
rm -f ~/.config/systemd/user/pi-web*.service
systemctl --user daemon-reload
rm -f ~/.config/pi-web/config.json
# 3. ~/.profile の「pi-web node bridge」ブロックを消す
```

なお `~/.pi/agent/npm/node_modules/@earendil-works` は **symlink の置き場** だけ
なので消して平気（本体の `~/.local/lib/node_modules/...` に影響しない）。

## 設計上の注意点（なぜこの形になったか）

- **flox が一切サービスに持ち込めない** → flox の `bin` などは
  interactive login shell（`-i`）経由で fish に exec しちゃうので、systemd の
  non-interactive `bash -lc` に node を見せる唯一の安全な入口が
  `~/.profile` の non-interactive ブランチ。これが土台の PATH bridge。
- **pi-web は `@earendil-works/*` を devDependency 扱いで import** → npm の
  `pi install` は node_modules に共有しに来ないので、pi-web が置かれる
  `~/.pi/agent/npm/node_modules` に symlink で手動提供。これが第 2 の土台。
- **systemd unit にキーを平書き** → EnvironmentFile が cleaner だが、unit は
  `pi-web install` のたび再生成される可能性があるので（ここでカスタムが生き延びる
 かは未検証）実用優先で Environment= を採用。再生成で消えるなら再貼付、
  または `~/.pi-web.env` に切り替えて unit を書くなり。

## 一言

日常的には「guest を起動 → ブラウザで `http://192.168.139.229:8504`」のみ。
それが効かないときだけ、このページの「よくある症状と対処」を開く、で十分なはず。
