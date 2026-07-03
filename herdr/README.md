# herdr セッション復元メモ

herdr は「永続サーバ + クライアント（画面）」型。作業状態（ワークスペース / タブ /
ペイン）はサーバが保持しており、画面を切り離しても消えない。復元は基本「アタッチし直す」だけ。

## 状況別の復元方法

### 1. スリープ / ノートの蓋を閉じただけ
サーバはメモリ上で生き続ける。開いたらそのまま繋ぎ直すだけ。

```bash
herdr        # 既定セッションに再アタッチ（そのまま復元）
```

### 2. クライアント切断（detach）した
画面だけ切れている状態。同じく再アタッチ。

```bash
herdr
```

### 3. パソコン再起動 / サーバ再起動した後
サーバは一度落ちるが、herdr がレイアウト（ワークスペース / タブ / ペイン構成）を復元する。
`config.toml` の `resume_agents_on_restore = true`（設定済み）により、
AI エージェント（claude / codex 等）のペインは元の会話セッションごと復帰する。
※ セッション参照を報告する公式インテグレーション対応エージェントに限る。

```bash
herdr        # 起動すると復元される
```

## 名前付きセッション

複数の作業空間を分けたいとき。

```bash
herdr --session work        # "work" に復帰（なければ作成）
herdr session list          # 一覧・状態確認
herdr session attach work   # 明示アタッチ
herdr session stop work     # 停止（状態は保持）
herdr session delete work   # 削除
```

## リモート（SSH 先）の復元

サーバはリモート側で走り続けるため、手元のノートを閉じても状態は生きている。
再接続すればそのまま復元される。リモートに herdr 未導入でも、初回接続時に自動導入される。

```bash
herdr --remote <ssh-target>                  # リモートの既定セッションへ
herdr --remote <ssh-target> --session work   # リモートの名前付きセッションへ
```

## 関連する config 設定（このリポジトリ）

`config.toml` に設定済み。

```toml
[session]
resume_agents_on_restore = true   # 再起動後もエージェント会話を復元
```

## 補足

- 現在の状態確認: `herdr status`
- 設定の再読込（サーバ再起動不要）: `herdr server reload-config`
