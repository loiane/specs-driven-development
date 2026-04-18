# Windsurf wrappers

This folder maps the shared agents/skills/commands to Windsurf's surface:

- `rules/*.md` — always-on rules. Windsurf has no pre-tool-use hook, so guardrails must be enforced as rules + workflow validation.
- `workflows/<name>.md` — slash-command workflows; one per command.

Each file is a thin pointer to `shared/`; the shared file is the single source of truth. Cross-platform parity is mandatory: the same prompt across Claude Code, Copilot, and Windsurf must produce the same artifacts.
