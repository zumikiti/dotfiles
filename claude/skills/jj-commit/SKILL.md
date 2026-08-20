---
model: Haiku
name: jj-commit
description: |-
  Jujutsuコミットガイド。
  【必須】以下の状況でこのスキルを参照すること:
  - jjリポジトリで変更を確定し、新しいchangeへ進む時
  - 複数ステップのタスクを実行中に、意味のある単位でchangeを区切る時
  Gitのstaging前提ではなく、jjのworking-copy commit前提で論理的な変更を扱うためのガイドラインです。
---

# Jujutsuコミットガイド

## changeを区切るタイミング

複数ステップのタスクを実行する際は、以下のタイミングで適宜changeを区切る:

- 1つの論理的な変更が完了した時（機能追加、バグ修正、リファクタリングなど）
- 次のステップに進む前に、現在の変更を確定させたい時
- テストが通る状態になった時

**やってはいけないこと:**
- すべての作業が終わってから一括で1つのchangeにまとめる
- 動作しない中途半端な状態でchangeを区切る
- Gitの感覚で`git add`相当の手順を探す

## jjの基本前提

- working copyは常に`@`で表されるcommitである
- 多くの`jj`コマンドは実行時にworking copyを自動snapshotし、`@`を更新する
- 新規ファイルや削除は既定で自動追跡されるため、通常は`add`不要
- 無視したいファイルは`.gitignore`に追加し、既に追跡された不要ファイルは`jj file untrack <path>`を使う
- change IDはcommitが書き換わっても安定するため、履歴操作ではcommit IDよりchange IDを優先する

## change確定手順

### 1. 状態の確認

以下を並列で実行:

- `jj status`（または`jj st`）でworking-copy commit、親、変更概要、conflictを確認
- `jj diff --git`で`@`の差分を確認（必要なら`jj diff --summary`でファイル一覧）
- `jj log -n 5`で直近のchange descriptionのスタイルを確認

### 2. 含める変更の確認

- jjでは通常stagingしない。`@`の内容が現在の論理的な変更になる
- 関係ない変更が混ざっている場合は、先に`jj split`、`jj squash -i`、`jj restore`などで論理単位に分ける
- `.env`、認証情報、`./claude/`ディレクトリ配下のファイルは意図せず含めない

### 3. change description

直近のchange descriptionのスタイルに倣い、以下のルールで作成する:

- **日本語**で記述する
- Conventional Commits のプレフィックスを付ける: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `modify:`, `test:` 等
- プレフィックスの後に半角スペースを1つ入れる
- 「何をしたか」を簡潔に書く（1行、50文字目安）
- 「何をしたか」に加えて、**diffを見ずとも影響が分かる**ことを基準にする
  - 悪い例: 「Fix/examples issue 127」（ブランチ名そのまま）、「修正」だけ
  - 良い例: `fix: モード名で始まるルール行がフィルタで消える問題を修正`
- エディタを開かない場合は`jj describe -m 'docs: jjコミットガイドを追加'`のように指定する

#### body（2行目以降）の指針

- 自明でない変更（バグ修正、挙動変更、トレードオフのある実装判断）には、descriptionの2行目以降にbodyを付ける。定型:
  1. 壊れ方・課題の観測事実
  2. 原因のメカニズム
  3. 修正方針と、**何を諦めたか（トレードオフ）**
  4. 回帰テストへの言及（「なぜ既存挙動を壊さないか」を関連Issue/PR/コミット番号で根拠づけられるとなお良い）
- 自明な変更（typo修正、単純なリネーム等）にbodyは不要。YAGNIはchange descriptionにも適用する
- bodyも日本語で書く

### 4. 新しいchangeへ進む

現在の`@`が1つの論理的な変更として整ったら、以下のいずれかを使う:

- `jj describe -m '<message>'`で現在の`@`に説明を付けてから、`jj new`で新しい空のchangeへ進む
- `jj commit -m '<message>'`で説明の更新と`jj new`をまとめて行う

`jj commit`は、path指定や`--interactive`なしなら`jj describe`の後に`jj new`するのと同等。path指定や`--interactive`を使うと、選んだ変更だけを現在のcommitに残し、残りを新しいworking-copy commitへ移す。

### 5. hookや検証が失敗した場合

- 失敗原因を修正する
- 修正が現在のchangeに属するなら、そのまま`@`を修正して`jj describe`や`jj squash`で整える
- 誤操作した場合は`jj op log`で操作履歴を確認し、必要なら`jj undo`で直前の操作を戻す

## change粒度の判断基準

**「1つの論理的な変更」ごとにchangeを区切る。**
判断基準は「このchangeだけを取り出して適用しても動作が成り立つか」という観点。

### 良い粒度の例

- ボタンのデザイン変更
- パスワードのバリデーション追加
- 不要なログ削除
- ユーザー登録のバックエンド実装（フロントエンドとは分ける）

### 避けるべきパターン

- **細かすぎる**: 変数名1つの変更、スペルミス修正だけで1change → 履歴が散らばり追跡困難
- **大きすぎる**: 「ログイン機能を実装」で新規ファイル・バグ修正・リファクタリング・設定変更をまとめる → レビュー困難

### 追加ルール

- 粒度は**タスク単位**で分ける。ファイル数ではなく論理的なまとまりで判断する
- 1changeで数百行を超える変更になる場合は、さらに分割できないか検討する（テストファイルの新規作成は例外として許容）
- changeを区切る前のテスト実行は必須ではない
- jjのchange作成はユーザーに確認せず自動で行ってよい。ただし、リポジトリの設定やhookには従うこと

参考:
- https://jj-vcs.github.io/jj/latest/tutorial/
- https://jj-vcs.github.io/jj/latest/working-copy/
- https://jj-vcs.github.io/jj/latest/cli-reference/
