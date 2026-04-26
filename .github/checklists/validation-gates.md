# Validation Gates Checklist

Used by `spring-validator` to gate exit from Phase 6.

## Hard gates (must be green or accepted as pre-existing baseline)

- [ ] Format & lint (Spotless, Checkstyle).
- [ ] Compile (`compile`, `test-compile`).
- [ ] Static analysis (SpotBugs, Error Prone).
- [ ] Architecture (ArchUnit rules: boundaries, no-cycles, internal-package isolation).
- [ ] Unit + slice tests (Surefire).
- [ ] Integration tests (Failsafe + Testcontainers, when present).
- [ ] Coverage: ≥90% line+branch overall and per-package; new code ≥95%.
- [ ] Mutation: no surviving mutants in changed packages (or ADR-justified).
- [ ] Contract: OpenAPI diff produces no breaking changes (or ADR-justified).
- [ ] Security: no new High/Critical CVEs (suppressions tracked in `dependency-check-suppressions.xml`).

## Reports parsed

- [ ] Surefire XML (`target/surefire-reports/`)
- [ ] Failsafe XML (`target/failsafe-reports/`)
- [ ] JaCoCo XML (`target/site/jacoco/jacoco.xml`)
- [ ] PIT XML (`target/pit-reports/mutations.xml`)
- [ ] Checkstyle XML (`target/checkstyle-result.xml`)
- [ ] SpotBugs XML (`target/spotbugsXml.xml`)
- [ ] OpenAPI diff JSON
- [ ] Dependency-check report

## Traceability

- [ ] `07a-traceability.md` produced.
- [ ] Zero ACs without a covering test.
- [ ] Zero orphan tests.
- [ ] Zero orphan code symbols (touched-by-diff and not test-covered).

## Baseline hygiene

- [ ] `.specs/_baseline.json` consulted.
- [ ] Any new entries flagged for code review (`major` unless ADR-justified).

## Sign-off

- [ ] `07-validation-report.md` written and passes its own checklist.
- [ ] Result line set to ✅ / ⚠️ / ❌ with correct rationale.
