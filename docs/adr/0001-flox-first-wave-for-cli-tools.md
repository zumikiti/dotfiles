# Flox first wave for CLI tools

We will introduce `flox` first as a Repo-local Entry Point for the First Wave of CLI Tools, while keeping `devbox` as the Development Toolchain for this repository. The First Wave is limited to `ripgrep`, `tmux`, `tig`, `oh-my-posh`, `lsd`, `zoxide`, and `fzf`, and only when they can be installed through `flox` with committed manifest and lockfiles under a Manual Update Policy. During the migration period, `flox activate` takes precedence inside the repo while `brew` remains a fallback outside it, and tools or install paths that cannot yet be locked are explicitly deferred to a later phase.

Deferred examples include `fish`, `fnm`, `fisher`, `tpm`, `lazy.nvim` bootstrap and update-check behavior, and installer paths such as `curl | bash` that do not meet the current Version-managed Installation bar.
