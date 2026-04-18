# Harness Principles

> **The agent validates its own work.** A human reviews the *result*, not every line.

## Why a harness, not vibes

Generative agents are confident even when wrong. The only durable defense is a deterministic, layered harness that runs the same way every time and is parsed automatically by the agent before it claims a task is done. If a layer regresses, the agent must address it before progressing — not narrate around it.

Hooks (Claude), guardrails (Copilot, Windsurf), and CI all invoke the **same** `scripts/harness.sh`. There is no second source of truth.

## Properties

1. **Deterministic.** Same commit → same gate outcome. No randomness, no time-based flake (`junit5-testcontainers-patterns` codifies clocks/IDs).
2. **Layered, fail-fast.** Cheap gates run first. The agent gets the most actionable feedback as early as possible.
3. **Incremental where it pays.** PIT and coverage have an incremental mode (changed packages / new code) so the inner loop stays fast; CI runs the full sweep.
4. **Parseable.** Every layer emits a machine-readable report (Surefire XML, JaCoCo XML/CSV, PIT XML, Checkstyle/SpotBugs XML, OpenAPI diff JSON). `harness-report-parsing` and `requirements-traceability` skills consume them.
5. **Baseline-aware.** Brownfield repos record pre-existing failures in `.specs/_baseline.json`. Only regressions block.
6. **Self-validating, not self-merging.** The agent must produce a green validation report and a green code review, but a human still approves the PR.

## The 10 layers

| # | Layer | Tool | Failure means |
|---|---|---|---|
| 1 | Format & lint | Spotless, Checkstyle | Style/format drift |
| 2 | Compile | `javac` (Maven) | Code does not build |
| 3 | Static analysis | SpotBugs, Error Prone | Bug-prone patterns |
| 4 | Architecture | ArchUnit | Boundary or layer violation |
| 5 | Unit + slice tests | JUnit 5, Surefire | Logic regression |
| 6 | Integration tests | JUnit 5, Failsafe, Testcontainers | DB / broker / external regression |
| 7 | Coverage | JaCoCo | <90% line+branch (per package + overall); new code <95% |
| 8 | Mutation | PIT | Surviving mutants in changed packages |
| 9 | Contract | OpenAPI generator + diff | Breaking API change |
| 10 | Security | OWASP Dependency Check | Known CVE in dependency tree |

Layers 1–6 always run. 7–10 are required for `/validate`. PIT is incremental locally, full in CI nightly.

## Coverage policy

- **Hard floor: 90%** line and branch (per package + overall, generated code excluded). Below this, the harness fails.
- **Goal: 95–100%.** Packages between 90% and 95% surface as `yellow` in `07-validation-report.md` and `minor` in `08-code-review.md` (or `major` if the package is in the changed set).
- **Incremental:** code introduced by the feature is held to **95%** via a coverage-diff check.

## Mutation policy

- PIT runs **incrementally** on packages touched by the active task.
- Surviving mutants in changed code surface as `major` in code review.
- Nightly CI runs PIT on the full module set and updates the baseline.

## Baselines

`.specs/_baseline.json` is committed to the repo so the agent can read it without network calls. It contains:

```json
{
  "generated_at": "2026-04-18T10:00:00Z",
  "harness_version": "1.0",
  "failures": {
    "checkstyle": ["..."],
    "spotbugs": ["..."],
    "coverage_below_threshold": ["com.example.legacy"],
    "pit_surviving": ["..."]
  }
}
```

A failure is a **regression** only if it is not in the baseline. Adding a baseline entry to silence a new failure is itself a code-review finding (`major`) unless accompanied by an ADR explaining the decision.

## Hard rules (non-negotiable)

- `mvn -DskipTests`, `-Dcheckstyle.skip`, `-Dpit.skip`, `--no-verify` are blocked everywhere.
- `@Disabled` without a `# DisabledReason: <link-to-issue>` comment is a `blocker`.
- Lowering coverage thresholds is a `blocker` unless paired with an ADR.
- Removing assertions or `verify(*)` calls without an ADR is a `blocker`.
- `08-code-review.md` must exist and be fresh (newer than the most recent code change) before `git commit`.

These are enforced by the `block-*` and `forbid-*` hooks in `.claude/hooks/`, mirrored in `.windsurf/rules/` and `.github/instructions/`.
