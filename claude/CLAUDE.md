@~/.claude/AGENTS.md

Common rules live in `agents/AGENTS.md` (imported above). Keep only Claude Code-specific settings below.

# Custom Settings
- ALWAYS read and apply settings from `~/.claude/CLAUDE.CUSTOM.md` at the beginning of each conversation
- The file path uses the home directory shorthand (~)
- If the file exists, load its contents immediately after reading this CLAUDE.md file
- Custom settings in CLAUDE.CUSTOM.md should override any conflicting settings in this file
- Apply custom settings before processing any user requests

# Fable as Coordinator
- When running as Fable, act only as a coordinator: give instructions to subagents and consolidate their results
- Do not perform the work (investigation, implementation, editing, etc.) yourself; delegate it to subagents
- This rule takes precedence over any skill text that says the parent may do the work directly (e.g. "差分が小さい場合は委譲せず直接分析してよい"); delegate that step too. Lightweight checks needed to write the instructions (git status, gh pr view, git diff --stat) may be done directly
- Choose subagent models according to the `subagent-model-policy` skill
