---
name: close-worktrees
description: workmux / wt (worktrunk) で作った git ワークツリーと tmux セッションを、clean かつ push 済みか確認した上で安全に閉じる。「workmux 閉じて」「ワークツリー片付けて」「wt 消して」「セッション終わったら閉じて」「worktree 掃除」「close worktree」「remove workmux session」「clean up worktrees」と言われたら使う。
---

# close-worktrees

driver `~/.claude/skills/close-worktrees/close.sh` が本体。cwd のリポジトリの `git worktree list --porcelain` から対象を特定し、パスに `__worktrees/` を含めば workmux 製、それ以外は wt 製と判定して、clean / push 済みを確認してから閉じる。

## 使い方

```bash
cd <リポジトリ>   # 本体でもワークツリー内でもよい
~/.claude/skills/close-worktrees/close.sh --dry-run <name>...   # まず確認
~/.claude/skills/close-worktrees/close.sh <name>...             # 閉じる
~/.claude/skills/close-worktrees/close.sh --delete-branch <name>  # ブランチも消す
~/.claude/skills/close-worktrees/close.sh --force <name>          # dirty / 未 push でも閉じる
```

- `<name>`: workmux の handle (`workmux status` で確認)、wt のブランチ名、ワークツリーのパスのいずれか。複数可。
- 引数なしは usage で終了 2。見つからない名前はスキップして終了 1。
- 内部で実行するコマンド: workmux 製は `workmux remove -f -k <handle>`、wt 製は `wt remove --foreground --no-delete-branch <branch>` (`--delete-branch` で `-k` / `--no-delete-branch` を外す、`--force` で wt 側に `-f`)。最後に `git worktree prune` と `git worktree list` を表示し、消した名前が残っていれば警告。

## 判定ルール

- 拒否 (スキップ、終了 1): 次のいずれか。理由を表示する。`--force` なら警告して続行。
  - `git status --porcelain --untracked-files=all` が空でない (未追跡ファイル含む)、または `git status` 自体が失敗 (パス消失など)
  - `git rev-list -n1 HEAD --not --remotes` が空でない (どのリモート追跡ブランチにも無いコミット = 未 push)
  - detached HEAD (`symbolic-ref -q HEAD` が失敗)
  - rebase / merge / cherry-pick / bisect の途中 (`rebase-merge` / `rebase-apply` / `MERGE_HEAD` / `CHERRY_PICK_HEAD` / `BISECT_LOG` のいずれかが存在)
- 未 push 判定は upstream に依存しない。upstream なし・upstream が gone のブランチも、リモートに無いコミットがあれば拒否する。リモート追跡ブランチは最後の fetch 時点の情報なので、push 済みかの最終確認は fetch 後が確実。
- ブランチは既定で残す (PR が open のことが多いため)。`--delete-branch` で初めて消す。
- 本体ワークツリー (`git worktree list` の 1 件目) は対象にならない。
- .gitignore 対象のファイル (コピーした `.env` / `.screenshot.env`、ローカル DB など) は確認しない。ワークツリーごと削除されるので、残したいものは先に退避する。

## Gotchas

- workmux は tmux 内で検証した (window も同時に消える)。tmux 外での動作は未検証。
- `wt switch --create` は「Cannot change directory — shell requires restart」と出るが、ワークツリー作成自体は成功する。
- `--force` なしで拒否された対象は終了コード 1。複数指定時は他の対象を処理した上で最後に 1 を返す。
- `--delete-branch` を付けずに一度閉じた後は、ブランチ名で再実行しても「見つからない」になる (ワークツリーが無いため)。ブランチ削除は `git branch -d` で行う。
- `--dry-run` は何も消さず、prune / 残存確認も走らない。

## Troubleshooting

- `[skip] <name>: 見つからない`: 名前の綴りか cwd のリポジトリが違う。`git worktree list` で確認。
- `[skip] <name>: 未コミットの変更あり` / `未 push のコミットあり` / `detached HEAD` / `途中`: 内容を確認して commit / push するか、捨ててよければ `--force`。
- squash マージ済みでリモートブランチが削除・prune されたものは「未 push」と出て拒否される。`gh pr view <branch> --json state` で `MERGED` を確認してから `--force` で閉じる。
