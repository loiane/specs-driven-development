# Spec-Driven Development — Codex instructions

You are working in a repo governed by a **spec-driven, self-validating workflow** defined in
`docs/methodology.md`. These instructions apply to every task unless a path-scoped `AGENTS.md`
overrides them.

## Read at session start

- `docs/methodology.md` — the seven phases.
- `docs/harness-principles.md` — the agent validates its own work.
- `docs/artifact-contract.md` — `.specs/<feature-id>/` file layout.
- `docs/spec-format.md` — EARS-lite ACs and `Q-NNN` open questions.

## Hard rules — phases 1, 2, 3 (spec, spec-review, design + tasks)

- **Never invent.** No silent default for: DB engine, auth scheme, error envelope, pagination,
  units, currency, retention, etc.
- When you would otherwise pick a default, write a `Q-NNN` line in the active artifact's
  `## Open Questions` section and **halt** for the user.
- Quote source tickets verbatim — never paraphrase requirements.
- AC IDs (`AC-NNN`) and task IDs (`T-NNN`) are stable; never renumber.

## Hard rules — phase 4 (build / TDD)

- **Never** edit `src/main/**` unless `.specs/<active-feature>/.tdd-state.json` shows
  `phase: red` with a non-empty `red_failure_excerpt` for the active task, AND the file is
  listed in that task's `files_in_scope`.
- Edit only files listed in the active task's `Files in scope` (in `04-tasks.md`).
- Never use `-DskipTests`, `-Dpit.skip`, `-Dcheckstyle.skip`, `-Dspotbugs.skip`, `--no-verify`.
- Never delete a test or remove an assertion.
- Never lower a coverage threshold.
- Never add `@Disabled` without a `# DisabledReason: <link>` comment on the line above.
- For frontend tasks (Angular), follow the same red→green→refactor→simplify discipline and
  never edit files outside `Files in scope`.

## Hard rules — phase 6 (validate) and phase 7 (review)

- Never modify production code or tests in these phases.
- A skipped test without `# DisabledReason` = error.
- A missing report for a configured layer = error.
- Every waiver references an ADR file.

## Spring Boot 4 conventions

See `.claude/skills/spring-boot-4-conventions/SKILL.md` for full details. Key rules:

- Constructor injection only (no `@Autowired` on fields).
- Package by feature/domain, not by layer. Top-level packages are bounded contexts (`api/`
  published surface; `model/`, `repository/`, `service/` private). No top-level `controller`,
  `service`, `repository`, or `dto` packages.
- `@HttpExchange` / `RestClient` for outbound HTTP (no new `RestTemplate`).
- Records for DTOs.
- `@MockitoBean` (not deprecated `@MockBean`).
- Slice tests over `@SpringBootTest` whenever possible.
- **No Lombok** in any new code (use records and explicit constructors).

## Frontend conventions (Angular track)

Apply Angular-focused skills when the active task touches frontend files:
- Use standalone components and route-level code splitting where practical.
- Use typed API clients/contracts; avoid ad-hoc untyped HTTP response handling.
- Keep component templates accessible (labels, button semantics, keyboard reachability).
- Cover validation rules with unit/component tests; do not rely on manual QA only.

## Slash commands

These commands drive the seven-phase workflow. When the user types one, follow the
corresponding agent's role description under `.claude/agents/`.

| Command | Agent / role | Phase |
|---|---|---|
| `/spec` | `spring-spec-author` | 1 — author EARS-lite spec |
| `/spec-review` | `spring-spec-author` | 2 — gate-exit review |
| `/plan` | `spring-architect` | 3 — design + tasks + ADRs |
| `/build <task-id>` | `spring-test-engineer` (red) → `spring-implementer` (green/refactor) | 4 — TDD loop |
| `/test` | `spring-test-engineer` | 5 — close coverage / mutation gaps |
| `/validate` | `spring-validator` | 6 — full harness + traceability |
| `/review` | `spring-code-reviewer` | 7 — pre-commit review |
| `/ship` | (ship checklist) | post-commit — release notes + rollout plan |
| `/onboard` | `spring-onboarding` | day-zero brownfield onboarding |
| `/code-simplify` | (clarity-over-cleverness skill) | anytime — simplify without behavior change |
| `/status` | (read-only) | anytime — pipeline status across features |
| `/help` | (read-only) | anytime — command catalog |

### Natural-language aliases

| Phrase | Equivalent command |
|---|---|
| "simplify the code" / "make this clearer" / "remove the cleverness" | `/code-simplify` |
| "spec this" / "turn this ticket into requirements" | `/spec` |
| "review the spec" | `/spec-review` |
| "plan this" / "design this" / "break into tasks" | `/plan` |
| "implement T-NNN" / "build T-NNN" | `/build T-NNN` |
| "validate" / "run the harness" | `/validate` |
| "review the code" / "pre-commit review" | `/review` |
| "ship it" / "release this" / "prepare release" | `/ship` |
| "onboard this repo" | `/onboard` |

## Agent roles (summary)

Read the full definition in `.claude/agents/<name>.md`.

| Agent | When active | Writes |
|---|---|---|
| `spring-spec-author` | `/spec`, `/spec-review` | `01-spec.md`, `02-spec-review.md` |
| `spring-architect` | `/plan` | `03-design.md`, `04-tasks.md`, `adr/NNN-*.md` |
| `spring-test-engineer` | `/build` (red step), `/test` | failing test; `06-test-plan.md` |
| `spring-implementer` | `/build` (green/refactor/simplify) | production code |
| `spring-validator` | `/validate` | `07-validation-report.md`, `07a-traceability.md` |
| `spring-code-reviewer` | `/review` | `08-code-review.md` |
| `spring-onboarding` | `/onboard` | `_onboarding.md`, `docs/known-debt.md` |
| `angular-architect` | `/plan` (frontend tasks) | `03-design.md` frontend sections, `04-tasks.md` |
| `angular-test-engineer` | `/build` (red, frontend) | failing frontend test |
| `angular-implementer` | `/build` (green/refactor, frontend) | Angular production code |
| `angular-validator` | `/validate` (frontend) | validation report (lint, typecheck, unit, e2e) |
| `angular-code-reviewer` | `/review` (frontend) | `08-code-review.md` |

## Cross-platform parity

The same prompt must produce the same artifacts regardless of whether you are Claude Code,
GitHub Copilot, Windsurf, or Codex. If you ever need to depart from this, write an ADR.
