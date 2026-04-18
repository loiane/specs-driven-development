# Shared command catalog

This folder is the **single source of truth** for the 12 slash commands.
Each `<name>.md` file describes the command in platform-neutral terms:

- **Purpose** — what the command does, in one sentence.
- **Phase** — which methodology phase it owns (or `meta`).
- **Owning agent** — which AGENT.md it routes to.
- **Inputs** — what the user supplies (arguments, free text, ticket URL).
- **Reads** — files the agent must consult before acting.
- **Writes** — files the agent is allowed to create/modify.
- **Process** — ordered steps the agent follows.
- **Refuse if** — preconditions; the command must abort with an explanation.
- **Done when** — exit conditions and the artifact handed to the next phase.

Platform wrappers (`.claude/commands/<name>.md`, `.github/prompts/<name>.prompt.md`,
`.windsurf/workflows/<name>.md`) are thin pointers to these files. Edit here, not
in the wrappers.

## Command index

| Command          | Phase     | Owning agent           |
|------------------|-----------|------------------------|
| `/onboard`       | 0         | spring-onboarding      |
| `/spec`          | 1         | spring-spec-author     |
| `/spec-review`   | 2         | spring-spec-author     |
| `/plan`          | 3         | spring-architect       |
| `/build`         | 4         | spring-implementer     |
| `/test`          | 4 (meta)  | spring-test-engineer   |
| `/validate`      | 5         | spring-validator       |
| `/review`        | 6         | spring-code-reviewer   |
| `/code-simplify` | 6 (meta)  | spring-code-reviewer   |
| `/ship`          | 8 (meta)  | spring-code-reviewer   |
| `/status`        | meta      | (no agent; read-only)  |
| `/help`          | meta      | (no agent; read-only)  |

## Natural-language aliases

Routed by `.claude/hooks/route-natural-language-aliases.sh` and documented in
each platform's instructions/rules:

- "simplify the code" → `/code-simplify`
- "spec this" / "turn this ticket into requirements" → `/spec`
- "review the spec" → `/spec-review`
- "plan this" / "break into tasks" → `/plan`
- "validate" / "run the harness" → `/validate`
- "review the code" → `/review`
- "ship it" / "release this" / "prepare release" → `/ship`
- "onboard this repo" → `/onboard`
