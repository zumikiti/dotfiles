# Dotfiles

Personal workstation configuration for shell, editor, terminal, and related tooling. This context exists to keep the language around tool management and installation policy consistent.

## Language

**CLI Tool**:
A command-line executable used interactively in the workstation environment, such as `fish`, `ripgrep`, `tmux`, or `tig`.
_Avoid_: app, package, dependency

**Development Toolchain**:
The repo-local set of tools required to lint, format, or otherwise work on this dotfiles repository itself.
_Avoid_: CLI tool, workstation tools

**Version-managed Installation**:
An installation path whose source and version are recorded in files committed to this repository.
_Avoid_: install, setup, latest

**First Wave**:
The initial set of CLI Tools selected for the first `brew` to `flox` migration.
_Avoid_: pilot, temporary set

**Repo-local Entry Point**:
An adoption step where `flox` definitions and lockfiles live in this repository, and activation begins from this repository before any wider rollout.
_Avoid_: local-only, global rollout

**Manual Update Policy**:
A rule that version-managed tool definitions and lockfiles change only through explicit user-initiated updates committed to this repository.
_Avoid_: auto update, rolling latest
