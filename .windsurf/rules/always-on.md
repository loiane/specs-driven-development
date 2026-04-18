---
trigger: always_on
description: "Spec-driven Spring Boot 4 — global guardrails that compensate for Windsurf's lack of a pre-tool-use hook."
---

# Always-on rules

You are working in a workspace governed by `docs/methodology.md` (seven-phase spec-driven workflow) and `docs/harness-principles.md` (the agent validates its own work).

## Read-first

At the start of every session, read:

- `docs/methodology.md`
- `docs/harness-principles.md`
- `docs/artifact-contract.md`
- `docs/spec-format.md`
- The active feature's `.specs/<feature-id>/` files, in numerical order.

## Hard rules — phases 1–3 (no invention)

- Never invent a default. When you would otherwise pick one (DB engine, auth, error envelope, pagination, units, currency, retention, etc.), append a `Q-NNN` to the active artifact's `## Open Questions` and **halt** for the user.
- Quote source tickets verbatim.
- Stable IDs — `AC-NNN`, `T-NNN`, `Q-NNN` are never renumbered.

## Hard rules — phase 4 (TDD)

- Before any edit to `src/main/**`, read `.specs/<active-feature>/.tdd-state.json`. Refuse the edit unless the active task's `phase == "red"` and `red_failure_excerpt` is non-empty AND the file is in `files_in_scope`.
- If you discover the precondition is not met, run the matching workflow first (e.g. invoke `spring-test-engineer` to write the failing test).
- Never use `-DskipTests`, `-Dpit.skip`, `-Dcheckstyle.skip`, `-Dspotbugs.skip`, `--no-verify`.
- Never delete a test or remove an assertion.
- Never add `@Disabled` without a `# DisabledReason: <link>` on the line above.
- Never lower a coverage threshold.

## Hard rules — phases 6 and 7

- `spring-validator` and `spring-code-reviewer` never edit production code or tests; they only write the validation/review artifact.
- A skipped test without `# DisabledReason` = error.
- A missing report for a configured layer = error.
- Every waiver references an ADR.

## Spring Boot 4 conventions

Apply `shared/skills/spring-boot-4-conventions/SKILL.md`, `archunit-rules/SKILL.md`, `spring-security-baseline/SKILL.md`.

Key rules: constructor injection only; package by feature/domain (not by layer); `@HttpExchange`/`RestClient` (no new `RestTemplate`); records for DTOs; `@MockitoBean` (not `@MockBean`); slice tests over `@SpringBootTest`; **no Lombok** in any new code.

## Natural-language aliases

| Phrase | Workflow |
|---|---|
| "simplify the code" / "make this clearer" | `/code-simplify` |
| "spec this" / "turn this ticket into requirements" | `/spec` |
| "review the spec" | `/spec-review` |
| "plan this" / "design this" / "break into tasks" | `/plan` |
| "implement T-NNN" / "build T-NNN" | `/build T-NNN` |
| "validate" / "run the harness" | `/validate` |
| "review the code" | `/review` |
| "ship it" / "release this" / "prepare release" | `/ship` |
| "onboard this repo" | `/onboard` |

## Cross-platform parity

The same prompt across Claude Code, Copilot, and Windsurf must produce the same artifacts. The shared content lives under `shared/` — never duplicate it inside `.windsurf/`.
