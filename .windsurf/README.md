# Windsurf — self-contained workspace

This folder maps the agents, skills, and commands to Windsurf's surface. It is fully self-contained.

- `rules/*.md` — always-on rules. Windsurf has no pre-tool-use hook, so guardrails are enforced as rules + workflow validation.
- `workflows/<name>.md` — slash-command workflows and agent definitions; one per command and per agent.
- `skills/<name>/SKILL.md` — full skill definitions.
- `templates/` — document templates.
- `checklists/` — review checklists.
- `maven/` — Maven POM fragments.

Each file contains the complete definition. Cross-platform parity is mandatory:
the same prompt across Claude Code, Copilot, and Windsurf must produce the same artifacts.

Scripts used by agents live in `.github/scripts/`.
