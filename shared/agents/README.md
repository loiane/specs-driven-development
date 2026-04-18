# Shared Agent Definitions

This folder holds **platform-neutral agent definitions**. Each `<agent-name>/AGENT.md` describes one role in the workflow: its purpose, when to invoke it, what skills it uses, what files it owns, and what gates it must pass before handing off.

The thin wrappers under `.claude/agents/`, `.github/chatmodes/`, and `.windsurf/workflows/` reference these by name; they should not duplicate content.

## The seven agents

| Agent | Phase | Owns |
|---|---|---|
| `spring-spec-author` | 1, 2 | `01-spec.md`, `02-spec-review.md` |
| `spring-architect` | 3 | `03-design.md`, `04-tasks.md`, ADRs |
| `spring-test-engineer` | 4 (red), 5 | failing tests, `06-test-plan.md` |
| `spring-implementer` | 4 (green/refactor/simplify) | production code, `05-implementation-log.md` updates |
| `spring-validator` | 6 | `07-validation-report.md`, `07a-traceability.md` |
| `spring-code-reviewer` | 7 | `08-code-review.md` |
| `spring-onboarding` | brownfield bootstrap | `.specs/_baseline.json`, `.specs/_starter-design.md`, `.specs/_known-debt.md` |

Each agent has an explicit handoff in/out and a strict no-assumptions posture for phases 1–3.
