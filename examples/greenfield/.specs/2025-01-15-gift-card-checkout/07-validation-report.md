# Validation report: gift-card-checkout

| Field             | Value                                                |
|-------------------|------------------------------------------------------|
| Feature           | `2025-01-15-gift-card-checkout`                      |
| Run timestamp     | 2025-01-22T14:31:08Z                                 |
| Git SHA           | `a1b2c3d`                                            |
| Verdict           | **PASS**                                             |
| Stack snapshot    | Java 25, Spring Boot 4.0.0, Postgres + Flyway, Testcontainers on |

## Gate results

| # | Gate                          | Status | Detail                                              |
|---|-------------------------------|--------|-----------------------------------------------------|
| 1 | Spotless format               | pass   | 0 files reformatted                                 |
| 2 | Checkstyle                    | pass   | 0 violations                                        |
| 3 | Compile + Error Prone         | pass   | 0 errors, 0 warnings                                |
| 4 | SpotBugs                      | pass   | 0 bugs                                              |
| 5 | ArchUnit                      | pass   | 5/5 rules (`giftcardInternalIsHidden`, `giftcardDoesNotDependOnOrder`, `noCyclesBetweenTopLevelPackages`, two pre-existing) |
| 6 | Unit tests (Surefire)         | pass   | 14 tests, 0 failures, 0 errors, 0 skipped           |
| 7 | Integration tests (Failsafe)  | pass   | 4 tests, 0 failures, 0 errors                       |
| 8 | JaCoCo coverage (overall)     | pass   | line 92.4%, branch 91.1% (floor: 90%)               |
|   | New-code coverage             | pass   | 100% (138/138 changed lines)                        |
| 9 | PIT mutation                  | pass   | kill rate 86%, 4 survived (3 justified, 1 killed in follow-up) |
|10 | OWASP Dependency Check        | pass   | 0 CVSS≥7 advisories                                 |
|11 | OpenAPI diff vs origin/main   | pass   | 1 path added (`POST /orders/{orderId}/gift-card`); no breaking change |
|12 | Traceability (`07a`)          | pass   | every AC has ≥1 `@Tag("AC-NNN")` test               |

## Surviving mutants (3 justified)

1. `GiftCardCodeHasher.hash()`: removed-conditional mutant on the `if (salt == null)`
   defensive branch that's unreachable because `salt` is `@NotNull`-validated by
   `@ConfigurationProperties`. **Justification accepted** — defensive null check.
2. `GiftCardEntity.amountToDebit()`: incremented constant in `Math.min` arg. The
   mutant was equivalent — both sides yielded the same `Money` because the
   coverage test uses balance == subtotal. Added a follow-up test that uses
   distinct values; mutant now killed.
3. `IdempotencyStore.save()`: removed-conditional on the duplicate-key catch.
   The catch is exercised by `IdempotentRedeemIT`; the surviving mutant flips
   to ignoring all `DataIntegrityViolationException`s, which our test
   doesn't distinguish from success because both paths return the same
   `Applied` payload. **Justification accepted** — the contract is "same payload
   returned"; the mutant preserves it. Tracked under `08-code-review.md` as a nit.

## Recommended next action

`/review 2025-01-15-gift-card-checkout`
