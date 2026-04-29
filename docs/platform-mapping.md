# Platform Mapping

How the spec-driven workflow is wired into Claude Code, GitHub Copilot, Windsurf, and Codex.
Each platform directory is self-contained — there is no shared source directory; every
behavioral change must be applied to all four platform layers.

## Mapping table

| Concept | Claude Code | GitHub Copilot | Windsurf | Codex |
|---|---|---|---|---|
| Skill | `.claude/skills/<name>/SKILL.md` | `.github/skills/<name>/SKILL.md` | `.windsurf/skills/<name>/SKILL.md` | referenced from `AGENTS.md` via `.claude/skills/` |
| Agent | `.claude/agents/<name>.md` (subagent) | `.github/chatmodes/<name>.chatmode.md` | `.windsurf/workflows/<name>.md` | role section in `AGENTS.md` |
| Slash command | `.claude/commands/<name>.md` | `.github/prompts/<name>.prompt.md` | `.windsurf/workflows/<name>.md` | command table in `AGENTS.md` |
| Always-on guardrail | `.claude/hooks/` + `settings.json` | `.github/instructions/always-on.instructions.md` | `.windsurf/rules/always-on.md` | `AGENTS.md` (root) |
| Path-scoped guardrail | (hook diff-check) | `.github/instructions/*.instructions.md` (`applyTo:` glob) | `.windsurf/rules/*.md` (`globs:`) | `<path>/AGENTS.md` |
| Template | `.claude/templates/` | `.github/templates/` | `.windsurf/templates/` | (read directly) |
| Checklist | `.claude/checklists/` | `.github/checklists/` | `.windsurf/checklists/` | (read directly) |

## Tool/permission model

Each agent has a strict permission boundary. The mechanism differs per platform:

| Boundary | Claude Code | Copilot | Windsurf | Codex |
|---|---|---|---|---|
| Allowed file globs | `allowed-tools` + hook diff-check | `tools` frontmatter + path-scoped instructions | rule frontmatter `globs:` + workflow scope | path-scoped `AGENTS.md` |
| Forbidden actions | PreToolUse hook | instruction file + `tools` allowlist | always-on rule + workflow validation step | root `AGENTS.md` hard rules |
| Required artifact present | PreToolUse hook | instruction (model-enforced) + workflow check | rule check at workflow entry | `src/main/AGENTS.md` precondition |
| Output-only file | hook on `Write` tool | instruction + chatmode `tools` excludes `editFiles` for prod paths | rule + workflow output validation | `AGENTS.md` role constraint |

Where Windsurf has no native pre-tool hook, the equivalent guarantee is encoded as:

1. an **always-on rule** that the model is instructed to obey, and
2. a **workflow validation step** that re-runs the harness and fails if the rule was violated, surfacing the violation for the user.

## Example: the `block-impl-without-failing-test` invariant

- **Claude Code:** `.claude/hooks/block-impl-without-failing-test.sh` is a PreToolUse hook on `Edit`/`Write` that reads `.specs/<feature-id>/.tdd-state.json`; refuses the call if no failing test was recorded for the active task.
- **Copilot:** `.github/instructions/guard-tdd.instructions.md` (applied to `src/main/**`) plus the `spring-implementer` chatmode whose `tools:` excludes `editFiles` until a `red` log entry exists. The `/build` prompt orchestrates phases sequentially.
- **Windsurf:** `.windsurf/rules/guard-tdd.md` (always-on, scoped to `src/main/**`) + the `/build` workflow which records and verifies `.tdd-state.json` between steps.
- **Codex:** `src/main/AGENTS.md` contains the TDD precondition check that the model must honour before editing any production file.

## Slash command equivalence

| Workflow | Claude Code | Copilot | Windsurf | Codex |
|---|---|---|---|---|
| `/spec` | `.claude/commands/spec.md` | `.github/prompts/spec.prompt.md` | `.windsurf/workflows/spec.md` | `AGENTS.md` command table |
| `/spec-review` | … `spec-review.md` | … `spec-review.prompt.md` | … `spec-review.md` | `AGENTS.md` command table |
| `/design` | … `design.md` | … `design.prompt.md` | … `design.md` | `AGENTS.md` command table |
| `/tasks` | … `tasks.md` | … `tasks.prompt.md` | … `tasks.md` | `AGENTS.md` command table |
| `/build <task-id>` | … `build.md` | … `build.prompt.md` | … `build.md` | `AGENTS.md` command table |
| `/code-simplify` | … `code-simplify.md` | … `code-simplify.prompt.md` | … `code-simplify.md` | `AGENTS.md` command table |
| `/test` | … `test.md` | … `test.prompt.md` | … `test.md` | `AGENTS.md` command table |
| `/validate` | … `validate.md` | … `validate.prompt.md` | … `validate.md` | `AGENTS.md` command table |
| `/review` | … `review.md` | … `review.prompt.md` | … `review.md` | `AGENTS.md` command table |
| `/commit` | … `commit.md` | … `commit.prompt.md` | … `commit.md` | `AGENTS.md` command table |
| `/baseline` | … `baseline.md` | … `baseline.prompt.md` | … `baseline.md` | `AGENTS.md` command table |

## MCP servers

Issue-tracker integration uses MCP. The core `issue-tracker-ingestion` skill is platform-neutral; each platform wires in MCP servers per its convention:

- **Claude Code:** `.mcp.json` at the workspace root or `~/.claude/mcp.json` (user scope).
- **Copilot:** MCP servers configured via VS Code settings; the chatmode lists allowed `mcp_*` tools.
- **Windsurf:** `.windsurf/mcp/` configuration files; the workflow whitelists relevant MCP servers.
- **Codex:** MCP support is environment-specific; configure via `codex --mcp-server` flags or the Codex config file.

The agent runs `.github/scripts/detect-stack.sh --mcp` at the start of `/spec` to enumerate available servers and pick one that matches the user's tracker.

## Drift control

Each platform layer is self-contained. Any behavioral change must be applied to all four
layers (`.claude/`, `.github/`, `.windsurf/`, and root `AGENTS.md` + path-scoped files).
CI lints for content that has diverged between platform copies of the same skill.
