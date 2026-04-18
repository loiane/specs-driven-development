# Spec-Driven Development for Spring Boot 4

A tri-platform toolkit (Claude Code · GitHub Copilot · Windsurf) that drives **Spring Framework 7 / Spring Boot 4** development through a documented, self-validating workflow:

> **specify → review → plan → implement (TDD) → test → validate → review → commit**

The agent validates its own work via a layered harness (build, static analysis, architecture, tests, coverage, mutation, contract, security) instead of relying on a human to inspect every line.

## Why

- **No invention.** During specify/review/plan/tasks, the agent never guesses; every uncertainty becomes a tracked open question that you answer before progress continues.
- **TDD by construction.** Production code can only be written *after* a failing test exists. Hooks enforce it.
- **Traceable.** Every acceptance criterion (`AC-NNN`) maps to tests, code, and the harness gates that exercised it.
- **Self-validating.** A single `scripts/harness.sh` runs locally and in CI; the agent reads its reports and writes a structured validation report.
- **Pre-commit code review** by an agent that uses a Spring-specific rubric.
- **Tri-platform** with a platform-neutral core; thin wrappers for each tool.

## Quickstart

```bash
# 0. (Brownfield only) classify the project and capture a baseline
/onboard

# 1. Start a feature (free text or ticket reference)
/specify "Add gift-card checkout"     # or: /specify JIRA-123

# 2. Walk through the workflow
/spec-review                          # checklist verdict on 01-spec.md
/plan                                 # produces 03-design.md + 04-tasks.md + .tdd-state.json
/build T-001                          # red → green → refactor → simplify (one task)
/test --gap                           # close any coverage / mutation gaps
/validate                             # full 10-layer harness + traceability + new-code coverage
/review                               # pre-commit code review against the Spring rubric
# Then YOU run: git commit (the agent never commits)
```

Two read-only helpers:

- `/status` — see where each feature sits in the pipeline.
- `/help [command]` — print the command catalog or a single command spec.

Natural-language aliases work too: *"simplify the code"* → `/code-simplify`,
*"spec this"* → `/specify`, *"validate"* → `/validate`, etc. Aliases are
documented in [shared/commands/README.md](shared/commands/README.md) and
enforced by `.claude/hooks/route-natural-language-aliases.sh`.

## Repository layout

```
docs/             methodology · harness-principles · spec-format · platform-mapping · artifact-contract
shared/           single source of truth (platform-neutral)
  ├ agents/       7 AGENT.md role files
  ├ skills/       20 SKILL.md domain knowledge files
  ├ commands/     11 command specifications
  ├ templates/    9 .specs/ artifact templates
  ├ checklists/   4 review/DoD/gate checklists
  └ maven/        parent-pom-fragment.xml (10-layer harness, pinned versions)
.claude/          agents · skills · commands · hooks · settings.json   (Claude Code wrappers)
.github/          chatmodes · prompts · instructions · workflows/harness.yml   (Copilot + CI)
.windsurf/        rules · workflows                                    (Windsurf wrappers)
scripts/          harness.sh · detect-stack.sh · check-new-code-coverage.sh · traceability.sh
examples/         greenfield (worked end-to-end) · brownfield (onboarding report)
```

The wrappers under `.claude/`, `.github/`, `.windsurf/` are intentionally thin
pointers — every behavioral change must be made in `shared/` so all three
platforms stay in lockstep.

## Workflow artifacts

Each feature lives under `.specs/<feature-id>/`:

| File | Phase | Owner |
|---|---|---|
| `01-spec.md` | Specify | `spring-spec-author` |
| `02-spec-review.md` | Review specs | `spring-spec-author` |
| `03-design.md` | Plan | `spring-architect` |
| `04-tasks.md` | Plan | `spring-architect` |
| `05-implementation-log.md` | Implement (TDD) | `spring-implementer` + `spring-test-engineer` |
| `06-test-plan.md` | Test | `spring-test-engineer` |
| `07-validation-report.md` | Validate | `spring-validator` |
| `07a-traceability.md` | Validate | `spring-validator` |
| `08-code-review.md` | Code review | `spring-code-reviewer` |

## Documentation

- [docs/methodology.md](docs/methodology.md) — the 7-phase workflow in detail
- [docs/harness-principles.md](docs/harness-principles.md) — self-validation philosophy and gate layers
- [docs/spec-format.md](docs/spec-format.md) — EARS-lite spec format with examples
- [docs/platform-mapping.md](docs/platform-mapping.md) — how Claude/Copilot/Windsurf artifacts map
- [docs/artifact-contract.md](docs/artifact-contract.md) — `.specs/<id>/` file layout and `.tdd-state.json` schema
- [examples/greenfield/README.md](examples/greenfield/README.md) — full worked feature
- [examples/brownfield/README.md](examples/brownfield/README.md) — onboarding-only walkthrough

## Stack assumptions

- Java 25, Spring Framework 7, Spring Boot 4
- Maven (Gradle support deferred)
- REST APIs with OpenAPI
- Module boundaries enforced via ArchUnit rules (no extra runtime dependency)
- DB engine + migration tool (Flyway/Liquibase) auto-detected from `pom.xml`
- Testcontainers integration tests are mandatory when Testcontainers is detected

## License

MIT.
