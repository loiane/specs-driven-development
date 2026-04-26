# Requirements Traceability Matrix: <FEATURE-ID>

> Owner: `spring-validator` · Phase 6 · Skill: `requirements-traceability`

## Matrix

| AC-ID | Tasks | Tests (status) | Code symbols | Gates exercised |
|---|---|---|---|---|
| AC-001 | T-001 | T-001-T1 ✅, T-001-T2 ✅ | `X#validate`, `X#apply` | unit, slice, IT, coverage |
| AC-002 | T-002 | T-002-T1 ✅, CONTRACT-001 ✅ | `Y#record`, `OrderReceipt#withRedemption` | unit, slice, contract |
| AC-003 | T-003 | T-003-T1 ✅ | `X#validate` | unit, slice |
| AC-004 | T-004 | T-004-T1 ✅, T-004-T2 ✅ | `X#guardOrderState` | unit, IT |
| AC-005 | T-005 | T-005-T1 ✅, PROP-001 ✅ | `X#applySequence` | unit, property |

## Coverage check

- ACs without a covering test: **0** (must be 0 for green)
- Tests without an AC link: **0** (orphan tests are flagged as findings)
- Code symbols touched by the diff without a covering test: **0**

## Test → AC tagging convention

Tests reference an AC via either:

```java
@Test
@DisplayName("AC-007: rejects expired card")
void rejectsExpiredCard() { ... }

// or

@Test
@Tag("AC-007")
void rejectsExpiredCard() { ... }
```

Both forms are recognized by the validator.

## Findings

- F-001: <description>
