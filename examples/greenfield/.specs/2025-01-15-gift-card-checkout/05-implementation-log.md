# Implementation log: gift-card-checkout

Each task contributes four blocks (red, green, refactor, simplify). Failing-test
output is quoted verbatim; the exact JSON state at the end of each phase is
mirrored in `.tdd-state.json`.

---

### T-001 — red

**Test added:** `GiftCardCodeHasherTest#hashesAreDeterministicAndDifferFromInput`

```java
@Test
@Tag("foundation")
@DisplayName("foundation: hashing is deterministic and obscures the code")
void hashesAreDeterministicAndDifferFromInput() {
    var hasher = new GiftCardCodeHasher("salt");
    byte[] a = hasher.hash("ABCD-1234-EFGH-5678");
    byte[] b = hasher.hash("ABCD-1234-EFGH-5678");
    assertArrayEquals(a, b);
    assertFalse(new String(a, StandardCharsets.UTF_8).contains("ABCD"));
}
```

**Failure (mvn test -Dtest=GiftCardCodeHasherTest):**
```
[ERROR] GiftCardCodeHasherTest.hashesAreDeterministicAndDifferFromInput  Time elapsed: 0.013 s  <<< ERROR!
java.lang.NoClassDefFoundError: com/example/checkout/giftcard/internal/GiftCardCodeHasher
```

`.tdd-state.json` after this phase:
```json
{ "active_task": "T-001", "tasks": { "T-001": { "phase": "red",
    "red_failure_excerpt": "NoClassDefFoundError: GiftCardCodeHasher",
    "files_in_scope": [...], "acs_covered": [] } } }
```

### T-001 — green

Implemented `GiftCardCodeHasher` with `MessageDigest.getInstance("SHA-256")`,
salt prefix, returns 32-byte array. Added `GiftCardEntity`, `GiftCardRepository`,
`GiftCardRedemptionEntity`, `GiftCardRedemptionRepository`, and Flyway script
`V1__gift_cards.sql` (verbatim from `03-design.md`).

**`mvn test`**: 1 unit test passes.
**`mvn -Dtest=GiftCardRepositoryIT verify`**: passes against Testcontainers
`postgres:16-alpine`. Container start ~2.4s, query ~12ms.

### T-001 — refactor

Extracted the salt source into a `@ConfigurationProperties("checkout.giftcard")`
record so production injects `${CHECKOUT_GIFTCARD_SALT}` from the environment;
test uses the literal `"salt"`. No behavior change. All tests still green.

### T-001 — simplify

Applied clarity-over-cleverness. Two changes:
- Inlined a private one-line `concatBytes()` helper used once.
- Renamed `GiftCardEntity.bal` → `remainingBalance` (no abbreviations).
Tests still green; no production behavior change.

`.tdd-state.json` after this phase: `T-001.phase = "done"`, `active_task = null`.

---

### T-002 — red

**Test added:** `DefaultGiftCardRedemptionServiceTest#appliesFullBalanceWhenCardCoversSubtotal`

```java
@Test
@Tag("AC-001")
@DisplayName("AC-001: full coverage debits the order subtotal and persists redemption")
void appliesFullBalanceWhenCardCoversSubtotal() { ... }
```

**Failure:**
```
[ERROR] DefaultGiftCardRedemptionServiceTest.appliesFullBalanceWhenCardCoversSubtotal
expected: Applied[amountApplied=Money[2500 USD], remainingBalance=Money[7500 USD]]
 but was: <service does not exist>
```

### T-002 — green

Implemented `DefaultGiftCardRedemptionService.redeem()` with a single happy
path: load by hash, check active+not expired+balance>=requested, debit, persist
`GiftCardRedemption`, return `Applied`. Added a partial-coverage test (AC-005)
which also passed without further code (the implementation already takes
`min(remainingBalance, subtotal)`).

`mvn verify`: 4 passed (2 new unit + 2 new IT).

### T-002 — refactor

Pulled the `min(remainingBalance, subtotal)` calculation into a named method
`amountToDebit(Money subtotal, Money balance)` on the entity — improves
readability, no behavior change. Tests still green.

### T-002 — simplify

Replaced an overly clever `Stream.of(card).filter(...).findFirst().map(...).orElseThrow(...)`
with an early `if (!card.isActiveAt(now)) throw ...` followed by straight-line
code. Removed an unused `Optional<Money>` return on a private helper.

---

### T-003 — red

Three rejection tests added (`AC-002`, `AC-003`, `AC-004`) plus an idempotency
integration test (`AC-006`). All four fail because the service currently throws
`NoSuchElementException` instead of returning `Rejected(code)`, and there is no
`IdempotencyStore`.

### T-003 — green

Switched all rejection paths to `return new Rejected(code)`. Added an
`IdempotencyStore` backed by the unique constraint on
`gift_card_redemption(gift_card_id, idempotency_key)`: on insert conflict the
existing row is loaded and the same `Applied` result is returned.

### T-003 — refactor

Extracted three guard clauses (unknown / expired / depleted) into a single
`Optional<String> reasonToReject(GiftCardEntity card, Instant now)` helper that
returns the error code or empty. Service body shrinks from 30 to 18 lines.

### T-003 — simplify

Removed an experimental `RejectionReason` enum that wrapped the strings — the
strings are the contract; an enum is premature abstraction with one impl.
All rejection codes now live as constants on `GiftCardRedemptionResult`.

---

### T-004 — red

`GiftCardControllerTest` (WebMvc slice) asserts 200 + JSON body for happy
path; 422 + ProblemDetail for each rejection. `GiftCardContractTest` runs
swagger-request-validator against `openapi.yaml`. All fail because the
controller class does not exist.

### T-004 — green

Added `GiftCardController.redeem(...)` mapping the JSON DTO to `RedeemCommand`,
delegating to `GiftCardRedemptionService`, mapping `Applied` → 200 and
`Rejected` → 422 with the existing ProblemDetail mapper. Updated `openapi.yaml`
with the new path. All slice + contract tests pass.

### T-004 — refactor

Moved DTO mapping into `GiftCardRedeemRequest.toCommand(orderId, idempotencyKey)`
so the controller stays thin. No behavior change.

### T-004 — simplify

Removed an `Optional<String>` parameter on the controller's response builder
that was always supplied — turned into a required parameter. Eliminated a
stale `// TODO: pagination` comment.

`.tdd-state.json` after T-004 simplify:
```json
{ "active_task": null,
  "tasks": {
    "T-001": { "phase": "done" },
    "T-002": { "phase": "done" },
    "T-003": { "phase": "done" },
    "T-004": { "phase": "done" } } }
```

All four tasks complete. Proceed to `/test --gap` (none expected) then `/validate`.
