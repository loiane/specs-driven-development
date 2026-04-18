---
applyTo: "**"
description: "Always-on guardrails for spec-driven Spring Boot 4 development."
---

# Spec-driven Spring Boot 4 — always-on guardrails

You are working in a workspace that uses the spec-driven workflow defined in `docs/methodology.md`. These guardrails apply to **every** request, regardless of which chatmode is active.

## Read these on every session

- `docs/methodology.md` — the seven phases.
- `docs/harness-principles.md` — the agent validates its own work.
- `docs/artifact-contract.md` — `.specs/<feature-id>/` file layout.
- `docs/spec-format.md` — EARS-lite ACs and `Q-NNN` open questions.

## Hard rules — phases 1, 2, 3 (spec, spec-review, design + tasks)

- **Never invent.** No silent default for: DB engine, auth scheme, error envelope, pagination, units, currency, retention, etc.
- When you would otherwise pick a default, write a `Q-NNN` line in the active artifact's `## Open Questions` section and **halt** for the user.
- Quote source tickets verbatim — never paraphrase requirements.
- AC IDs (`AC-NNN`) and task IDs (`T-NNN`) are stable; never renumber.

## Hard rules — phase 4 (build)

- TDD only. **Never** edit `src/main/**` unless `.specs/<active-feature>/.tdd-state.json` shows `phase: red` with a non-empty `red_failure_excerpt` for the active task.
- Edit only files listed in the active task's `Files in scope` (in `04-tasks.md`).
- Never use `-DskipTests`, `-Dpit.skip`, `-Dcheckstyle.skip`, `-Dspotbugs.skip`, `--no-verify`.
- Never delete a test or remove an assertion.
- Never lower a coverage threshold.
- Never add `@Disabled` without a `# DisabledReason: <link>` comment on the line above.

## Hard rules — phase 6 (validate) and phase 7 (review)

- Never modify production code or tests in these phases.
- A skipped test without `# DisabledReason` = error.
- A missing report for a configured layer = error.
- Every waiver references an ADR file.

## Spring Boot 4 conventions

Apply `shared/skills/spring-boot-4-conventions/SKILL.md`:
- Constructor injection only (no `@Autowired` on fields).
- Package by feature/domain, not by layer (top-level packages are bounded contexts with `api`/`internal` sub-packages).
- `@HttpExchange` / `RestClient` for outbound HTTP (no new `RestTemplate`).
- Records for DTOs.
- `@MockitoBean` (not deprecated `@MockBean`).
- Slice tests over `@SpringBootTest` whenever possible.
- **No Lombok** in any new code (use records and explicit constructors).

## Natural-language aliases

When the user types these phrases, treat them as the corresponding command:

| Phrase | Command |
|---|---|
| "simplify the code" / "make this clearer" / "remove the cleverness" | `/code-simplify` |
| "spec this" / "turn this ticket into requirements" | `/specify` |
| "review the spec" | `/spec-review` |
| "plan this" / "design this" / "break into tasks" | `/plan` |
| "implement T-NNN" / "build T-NNN" | `/build T-NNN` |
| "validate" / "run the harness" | `/validate` |
| "review the code" / "pre-commit review" | `/review` |
| "onboard this repo" | `/onboard` |

## Cross-platform parity

The same prompt across Claude Code, GitHub Copilot, and Windsurf must produce the same artifacts. If you ever need to depart from this, write an ADR explaining why.
