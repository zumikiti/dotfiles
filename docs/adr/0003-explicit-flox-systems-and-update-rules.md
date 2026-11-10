# Explicit flox systems and update rules

We will declare `[options] systems = ["aarch64-darwin", "aarch64-linux"]` explicitly in the `flox` manifest, and follow a few fixed rules when updating it. This builds on the Manual Update Policy in [CONTEXT.md](../../CONTEXT.md) and [ADR 0001](0001-flox-first-wave-for-cli-tools.md).

**Systems are explicit.** With `options.systems` unset, `flox` ≤ 1.14 implicitly included `x86_64-darwin`, which silently held package resolution (and so upgrades) back to older versions ([discourse](https://discourse.flox.dev/t/x86-64-darwin-environments-may-resolve-to-older-package-versions/1268)). nixpkgs 26.05 is also the last release supporting `x86_64-darwin`. The only machines in use are an aarch64 Linux VM (OrbStack) and an Apple Silicon Mac, so only those two are listed. Adding a system later is a one-line change. Per-package `systems` lists must stay within these two.

**Version constraints live only in single-package pkg-groups.** An exact `version` in `toplevel` or in a shared group freezes the whole group, because the group resolves against one nixpkgs revision. A pin is allowed only on a package in its own `pkg-group`; the lockfile is the pin for everything else. The existing `toplevel` pins (`worktrunk`, `jq`, `htop`, `gh-dash`) predate this rule and are a known deviation until they are removed in a follow-up update.

**Never merge a raise of `schema-version` or `lockfile-version` until every machine's `flox` CLI supports it.** The Login Bootstrap activates `flox` at login, so an older CLI that cannot read the manifest or lockfile breaks the login environment.

**Review every lock diff.** `flox` commands re-lock silently after any manifest edit (even `--dry-run` or `flox list`), so dry-run output is not proof of what changes; the `manifest.lock` diff per system is. Never run `flox activate -d <worktree>` with the real `HOME`: the Activation Hook would repoint the live dotfiles symlinks to that worktree. Use a fake `HOME` and scratch `XDG_*` directories to test the hook.
