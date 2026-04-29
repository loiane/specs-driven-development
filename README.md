# Spec-Driven Development for Spring Boot 4

A quad-platform toolkit (Claude Code · GitHub Copilot · Windsurf · Codex) that drives **Spring Framework 7 / Spring Boot 4** development through a documented, self-validating workflow:

> **specify → review → plan → implement (TDD) → test → validate → review → commit**

The agent validates its own work via a layered harness (build, static analysis, architecture, tests, coverage, mutation, contract, security) instead of relying on a human to inspect every line.

## Why

- **No invention.** During specify/review/plan/tasks, the agent never guesses; every uncertainty becomes a tracked open question that you answer before progress continues.
- **TDD by construction.** Production code can only be written *after* a failing test exists. Hooks enforce it.
- **Traceable.** Every acceptance criterion (`AC-NNN`) maps to tests, code, and the harness gates that exercised it.
- **Self-validating.** A single `.github/scripts/harness.sh` runs locally and in CI; the agent reads its reports and writes a structured validation report.
- **Pre-commit code review** by an agent that uses a Spring-specific rubric.
- **Quad-platform** — Claude Code, GitHub Copilot, Windsurf, and Codex all driven by the same workflow and artifacts.

## Install

This toolkit is a **set of files you drop into your repo**, not a package you `npm install` or `mvn install`. Pick the path that matches your situation.

### Prerequisites

- Java 25 + Maven 3.9+ (for the harness to actually run).
- At least one supported agent surface installed:
  - [Claude Code](https://docs.claude.com/en/docs/claude-code) (uses `.claude/`)
  - [GitHub Copilot in VS Code](https://code.visualstudio.com/docs/copilot/overview) with chat enabled (uses `.github/`)
  - [Windsurf](https://windsurf.com/) (uses `.windsurf/`)
  - [Codex CLI](https://github.com/openai/codex) (uses `AGENTS.md` at root + path-scoped `AGENTS.md` files)
- `bash`, `git`, `jq` on your `PATH` (the harness scripts use them).

You only need the directories for the agent(s) you actually use; the others can be deleted.

### Option A — Start a new project from this toolkit

```bash
# 1. Clone (or use as a template)
git clone https://github.com/loiane/specs-driven-development.git my-service
cd my-service
rm -rf .git && git init

# 2. Drop in your own Spring Boot 4 application code under src/
#    Merge .claude/maven/parent-pom-fragment.xml into your pom.xml
#    (it pins the 10-layer harness: Surefire, Failsafe, JaCoCo, PIT, Checkstyle,
#    SpotBugs, ArchUnit deps, OWASP dep-check, OpenAPI generator).

# 3. Make the scripts executable
chmod +x .github/scripts/*.sh

# 4. Verify the harness wires up
./.github/scripts/harness.sh --dry-run     # lists the 10 gates without running them
```

### Option B — Add the toolkit to an existing Spring repo

```bash
# From the root of your existing repo:
git clone --depth=1 https://github.com/loiane/specs-driven-development.git /tmp/sdd

# Copy only what you need (skip the agent dirs you won't use):
cp -r /tmp/sdd/{docs,examples} .
cp -r /tmp/sdd/.claude   .   # if you use Claude Code
cp -r /tmp/sdd/.github   .   # if you use Copilot   (merges with existing .github/)
cp -r /tmp/sdd/.windsurf .   # if you use Windsurf
cp /tmp/sdd/AGENTS.md    .   # if you use Codex (also copy src/main/AGENTS.md, src/test/AGENTS.md, .specs/AGENTS.md)

chmod +x .github/scripts/*.sh

# Then merge .claude/maven/parent-pom-fragment.xml into your pom.xml.
# Then run the brownfield onboarding command from your agent (see Use below).
```

> **Note on `.github/`** — if you already have `.github/workflows/`, review
> `.github/workflows/harness.yml` before copying so it doesn't clobble yours.
> The toolkit ships two workflows:
>
> | Workflow | Purpose | When to keep |
> |---|---|---|
> `ci.yml` | Validates the toolkit itself (shellcheck, YAML lint, broken links, skill structure) | Only in the **toolkit repo** — delete it from your Spring project |
> `harness.yml` | Runs the full 10-layer Spring harness (build, tests, coverage, mutation, etc.) | Only in your **Spring project** — it requires a `pom.xml` |

### Verify per-platform wiring

| Platform | Smoke test |
|---|---|
| Claude Code  | Open the repo, run `/help` — you should see the command catalog. |
| Copilot      | Open Copilot Chat, type `/spec` — you should see the chat-mode prompt from `.github/chatmodes/`. |
| Windsurf     | Open Cascade, type `/spec` — Windsurf loads the workflow from `.windsurf/workflows/`. |
| Codex        | Run `codex "spec this feature"` — Codex reads `AGENTS.md` and follows the spec-author role. |

## Use

Once installed, you drive everything from your agent's chat using slash commands. The same commands work on all three platforms.

### Day-zero (brownfield only)

```text
/onboard
```

Classifies the repo, captures a baseline harness run, writes
`.specs/_onboarding.md` and `docs/known-debt.md`, and adds any missing harness
layers as ratchets (so existing failures don't block you, but no new ones can
land). See [examples/brownfield/README.md](examples/brownfield/README.md).

### Per-feature loop

```text
/spec "Add gift-card checkout"      # or: /spec JIRA-123
/spec-review                        # gate exit from Phase 1
/plan                               # design + tasks + .tdd-state.json
/build T-001                        # red → green → refactor → simplify (one task at a time)
/test --gap                         # close coverage / mutation gaps
/validate                           # full 10-layer harness + traceability
/review                             # pre-commit code review against the Spring rubric
git commit                          # YOU run this — the agent never commits
/ship                               # post-commit ship plan + release notes (never deploys)
```

Repeat `/build T-NNN` for each task in `04-tasks.md`. The agent refuses to edit
`src/main/**` unless `.specs/<feature-id>/.tdd-state.json` shows a failing test
for the active task.

### Read-only helpers

- `/status` — see where each feature sits in the pipeline.
- `/help [command]` — print the command catalog or a single command spec.

### Natural-language aliases

You don't have to remember the slash names. These phrases are routed to the
right command by [.claude/hooks/route-natural-language-aliases.sh](.claude/hooks/route-natural-language-aliases.sh)
and the equivalent Copilot/Windsurf instructions:

| You type | Runs |
|---|---|
| "spec this" / "turn this ticket into requirements" | `/spec` |
| "review the spec" | `/spec-review` |
| "plan this" / "design this" | `/plan` |
| "implement T-003" / "build T-003" | `/build T-003` |
| "validate" / "run the harness" | `/validate` |
| "review the code" / "pre-commit review" | `/review` |
| "simplify the code" / "remove the cleverness" | `/code-simplify` |
| "ship it" / "release this" / "prepare release" | `/ship` |
| "onboard this repo" | `/onboard` |

Full list: see `.claude/commands/` for all command specifications.

### Running the harness directly

The same gates the agent runs are reachable from a normal terminal:

```bash
./.github/scripts/harness.sh                 # all 10 layers
./.github/scripts/harness.sh --layer tests   # one layer
./.github/scripts/check-new-code-coverage.sh # diff-coverage gate against main
./.github/scripts/traceability.sh <feature-id>
```

## Repository layout

```
docs/             methodology · harness-principles · spec-format · platform-mapping · artifact-contract
AGENTS.md         Codex root instructions (always-on guardrails + slash-command catalog)
src/main/         → AGENTS.md  Codex production-code guardrails (TDD precondition + Spring conventions)
src/test/         → AGENTS.md  Codex test-code guardrails
.specs/           → AGENTS.md  Codex spec-artifact guardrails
.claude/          agents · skills · commands · hooks · settings.json   (Claude Code)
.github/          chatmodes · prompts · instructions · skills · workflows/{ci,harness}.yml   (Copilot + CI)
.windsurf/        rules · workflows · skills                            (Windsurf)
examples/         greenfield (worked end-to-end) · brownfield (onboarding report)
```

The platform layers under `.claude/`, `.github/`, `.windsurf/`, and the root `AGENTS.md`
are self-contained — every behavioral change must be applied to all four platforms.
See `docs/platform-mapping.md` for the full concept-to-file mapping.

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
- [docs/platform-mapping.md](docs/platform-mapping.md) — how Claude/Copilot/Windsurf/Codex artifacts map
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
