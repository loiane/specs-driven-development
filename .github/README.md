# GitHub Copilot wrappers

This folder maps the shared agents/skills/commands to Copilot's surface:

- `chatmodes/<agent>.chatmode.md` — one per shared agent. Copilot's "chat mode" is the closest analog to a Claude subagent.
- `instructions/*.instructions.md` — globally-applied or path-scoped guardrails (no-assumptions, TDD discipline, harness rules). These are loaded automatically by Copilot for matching files.
- `prompts/<command>.prompt.md` — one per slash command. Triggered via `/command-name` in Copilot Chat.

Each file is a thin pointer to `shared/`; the shared file is the single source of truth.

Reference: VS Code customization docs for Copilot chat (instructions, prompts, chatmodes).
