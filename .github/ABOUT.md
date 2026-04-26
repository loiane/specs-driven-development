# GitHub Copilot — self-contained workspace

This folder maps the agents, skills, and commands to Copilot's surface. It is fully self-contained.

- `chatmodes/<agent>.chatmode.md` — one per agent. Copilot's "chat mode" is the closest analog to a Claude subagent.
- `instructions/*.instructions.md` — globally-applied or path-scoped guardrails (no-assumptions, TDD discipline, harness rules). These are loaded automatically by Copilot for matching files.
- `prompts/<command>.prompt.md` — one per slash command. Triggered via `/command-name` in Copilot Chat.
- `skills/<name>/SKILL.md` — full skill definitions.
- `templates/` — document templates.
- `checklists/` — review checklists.
- `maven/` — Maven POM fragments.
- `.github/scripts/` — shell scripts used by agents and CI.
- `workflows/` — CI/CD workflows.

Each file contains the complete definition. Cross-platform parity with `.claude/` and `.windsurf/` is mandatory.

Reference: VS Code customization docs for Copilot chat (instructions, prompts, chatmodes).
