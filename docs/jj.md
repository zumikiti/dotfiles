# jj (Jujutsu) チートシート

日々の作業で質問した内容のまとめ。思い出し用。

## ブックマークを特定の revision に動かす

「rx の commit を feat/herdr にのせたい」= ブックマークを動かす。

```bash
# 子孫方向（前進）への移動。そのまま動かせる
jj bookmark set feat/herdr -r rx

# リモートへ反映
jj git push -b feat/herdr
```

## ブックマークを後退させる（--allow-backwards）

ブックマークを**いまの指し先の祖先や別系統の commit** へ動かすときは
`--allow-backwards` が必要。

```bash
jj bookmark set feat/pi-dotfiles -r tw --allow-backwards
```

- 前進（子孫方向）: 履歴が伸びる自然な流れなのでフラグ不要
- 後退（祖先・別系統）: 「一度ブランチに含めた commit をなかったことにする」動き。
  push 済みなら force push 相当になり、他人の作業と食い違う恐れがあるため
  明示的なフラグで確認を挟む設計になっている
- 使いどころ: 間違って進んだブックマークを戻す、リリースブランチの巻き戻し、
  履歴の作り直しで別系統へ付け替える、など

## ブランチ（ブックマーク）の位置に切り替える

git の checkout に相当するのは `jj new`。

```bash
# feat/herdr の上に新しい作業コピー commit を作って @ を移す
jj new feat/herdr

# その commit 自体を直接編集したいとき（変更が commit に直接吸い込まれる）
jj edit feat/herdr
```

- 空で説明もない `@` は、離れた時点で jj が自動破棄してくれる
- ブックマークは自動では進まない。commit を積んだ後は
  `jj bookmark set feat/herdr -r @` で進める

## リベース

```bash
# 枝まるごと（分岐点以降すべて）を feat/herdr の上へ
jj rebase -b feat/pi-dotfiles -d feat/herdr

# 指定 commit とその子孫だけ
jj rebase -s <rev> -d feat/herdr

# 指定 commit ひとつだけ
jj rebase -r <rev> -d feat/herdr
```

git との違い:

- ブックマークは rebase 後の commit へ自動でついてくる（張り直し不要）
- コンフリクトが出ても途中で止まらない。衝突は commit 内に記録されて
  rebase は完走し、あとで `jj status` を見ながら好きな順に解決できる

## 特定 revision からファイルを取得する

```bash
# 中身を表示するだけ（git show rev:path 相当）
jj file show -r <rev> path/to/file

# 別ファイルに保存
jj file show -r <rev> path/to/file > 保存先

# 作業コピーへ復元（git restore --source=<rev> -- path 相当）
jj restore --from <rev> path/to/file

# revision 内のファイル一覧
jj file list -r <rev>
```

`<rev>` には change id（例: tw）、commit hash（例: cfa30427）、
ブックマーク名のいずれも使える。
