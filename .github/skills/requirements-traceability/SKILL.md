---
name: requirements-traceability
description: Build and verify the AC ↔ tasks ↔ tests ↔ code symbols ↔ gates traceability matrix in `07a-traceability.md`. Use when validating that no AC is uncovered and no test is orphaned.
when_to_use:
  - Phase 6 (Validate) — `/validate` produces the matrix.
  - Code review — verify the matrix is consistent with actual files.
authoritative_references:
  - .github/templates/traceability.template.md
---

# Requirements traceability

## What gets traced

For each `AC-NNN` from `01-spec.md`:

- The list of `T-NNN` tasks that implement it (`04-tasks.md`).
- The list of test methods that assert it (`@Tag("AC-NNN")` or `@DisplayName("AC-NNN: …")`).
- The list of production code symbols (FQ method names) touched by those tasks' diffs.
- The list of harness gates that ran on those symbols.

For each test method:

- The AC it claims to assert.
- The task that introduced it.

For each production symbol changed in the diff:

- At least one test that covers it (else flagged "orphan code").

## Building the matrix

`spring-validator` runs `.github/scripts/traceability.sh` which:

1. Greps `01-spec.md` for `**AC-NNN**` headers → AC list.
2. Greps `04-tasks.md` for task entries with `**AC-IDs:**` → AC↔task mapping.
3. Scans `src/test/java/**/*.java` for `@Tag("AC-NNN")` and `@DisplayName("AC-NNN: …")` → AC↔test mapping.
4. Reads `git diff --name-only origin/main...HEAD` → changed files; intersects with JaCoCo's per-method coverage data → covered/uncovered symbols.
5. Reads `harness-summary.json` → gates that ran.
6. Emits `07a-traceability.md`.

## Required checks (all must pass)

- **No uncovered AC.** Every `AC-NNN` appears in ≥1 test's `@Tag` or `@DisplayName`.
- **No orphan test.** Every test method tagged `AC-NNN` references a real AC.
- **No orphan code.** Every changed production method has ≥1 covering test.
- **No untraced task.** Every `T-NNN` marked `done` in `04-tasks.md` has a commit recorded.

Failures of any check → validator returns ❌.

## Sample output (truncated)

```markdown
## Coverage

| AC-ID | Tasks | Tests | Status |
|-------|-------|-------|--------|
| AC-001 | T-001, T-002 | ApplyGiftCardRequestTest#rejectsBlankCode, CheckoutControllerTest#happyPath | ✅ |
| AC-002 | T-003 | CheckoutServiceTest#redeemedCardRejected, CheckoutControllerIT#redeemed409 | ✅ |
| AC-003 | T-002 | CheckoutControllerTest#unknownCode404 | ✅ |
| AC-004 | T-004 | GiftCardRepositoryIT#balanceAcrossOrders | ✅ |

## Orphan tests

_None._

## Orphan code

_None._

## Verdict

✅ All ACs covered. No orphans.
```

## Tagging convention (enforced)

```java
@Test
@DisplayName("AC-007: rejects expired gift card with 4xx")
@Tag("AC-007")
void rejectsExpired() { ... }
```

Both `@DisplayName` and `@Tag` are written for redundancy — one is human-friendly, the other machine-friendly.

A Checkstyle rule rejects test methods that have `@DisplayName` matching `^AC-\\d{3}:` without a matching `@Tag`.

## Anti-patterns

- One mega-test that asserts five ACs at once → split.
- Tests that only tag the highest-numbered AC of a related group → tag every AC asserted.
- "Tag and forget" — agent tags the test but the assertion doesn't actually exercise the AC.
- Removing a tag to make traceability green.
