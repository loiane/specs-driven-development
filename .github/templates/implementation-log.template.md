# Implementation Log: <FEATURE-ID>

> Owner: `spring-test-engineer` + `spring-implementer` · Phase 4 · Append-only

Each task contributes a `red`, `green`, `refactor`, and `simplify` block. Format below.

---

## T-001 — <task title>

### red — <YYYY-MM-DDTHH:MM:SSZ>

- Tests added: `src/test/java/<...>/XTest#shouldRejectExpiredCard` (T-001-T1)
- Command: `mvn -q -Dtest=XTest#shouldRejectExpiredCard test`
- Result: **failed as expected** — `AssertionFailedError: expected status 400 but was 200`
- Notes: <if anything is unusual>

### green — <YYYY-MM-DDTHH:MM:SSZ>

- Files edited: `src/main/java/<...>/X.java`
- Diff size: +12 −0
- Command: `mvn -q -Dtest=XTest#shouldRejectExpiredCard test`
- Result: **passed**
- Notes: <minimum implementation; nothing extra>

### refactor — <YYYY-MM-DDTHH:MM:SSZ>

- Files edited: `src/main/java/<...>/X.java`
- Changes: extracted private helper `validateExpiry`; no behavior change.
- Command: `mvn -q verify -pl <module>`
- Result: **passed** (suite green)

### simplify — <YYYY-MM-DDTHH:MM:SSZ>

- Files edited: `src/main/java/<...>/X.java`
- Changes:
  - inlined single-use helper `formatErrorCode` (clarity-over-cleverness)
  - replaced ternary chain with switch-expression
- Command: `mvn -q verify -pl <module>`
- Result: **passed**

---
