# /validate

**Phase:** 5 — validate (run the harness)
**Owning agent:** `shared/agents/spring-validator.md`
**Skills used:** `harness-report-parsing`, `jacoco-coverage-policy`, `pit-mutation-tuning`, `requirements-traceability`, `archunit-rules`

## Purpose
Run the full 10-layer harness, parse the output, and write `07-validation-report.md` with a single `PASS` / `FAIL` verdict.

## Inputs
- `<feature-id>` (optional; if omitted, reports across all changes since `origin/main`).

## Reads
- `scripts/harness.sh`, `scripts/check-new-code-coverage.sh`, `scripts/traceability.sh`.
- `target/harness-summary.json` (after the run).
- `01-spec.md`, `04-tasks.md`, `06-test-plan.md` (for AC mapping).

## Writes
- `.specs/<feature-id>/07-validation-report.md`
- `.specs/<feature-id>/07a-traceability.md` (regenerated)
- `target/harness-summary.json`, `target/new-code-coverage.json`

## Process
1. Run `scripts/harness.sh --report > /dev/null` (writes `target/harness-summary.json`).
2. Run `scripts/check-new-code-coverage.sh` (must be ≥ 95% on changed lines).
3. Run `scripts/traceability.sh <feature-id>`. Any AC with zero tests = FAIL.
4. Aggregate the 10 gates plus the new-code-coverage and traceability checks. Verdict is `PASS` only if every gate is `pass` (mutation may be `warn` if explicitly justified in the report).
5. Write `07-validation-report.md` with: verdict, gate table, top failing items, links to artifacts, recommended next action.

## Refuse if
- `04-tasks.md` shows any task not `done`.
- The harness was bypassed (e.g. local cache showed stale results) — always re-run.
- `forbid-skip-flags.sh` would have blocked the underlying Maven invocation.

## Done when
`07-validation-report.md` exists with a clear verdict. If `PASS`, point the user to `/review`. If `FAIL`, list the smallest set of `/build` or `/test` actions needed to recover.
