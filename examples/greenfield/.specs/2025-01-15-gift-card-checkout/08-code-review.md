# Code review: gift-card-checkout

| Field        | Value                                            |
|--------------|--------------------------------------------------|
| Reviewer     | spring-code-reviewer                             |
| Base ref     | `origin/main`                                    |
| Validation   | PASS (see `07-validation-report.md`)             |
| Verdict      | **APPROVE** (0 must-fix, 2 should-fix, 3 nits)   |

## Findings

### must-fix (0)

*(none)*

### should-fix (2)

1. **`GiftCardController.redeem()`** — the `@RequestBody` DTO is missing
   `jakarta.validation.constraints.@NotBlank` on `cardCode`. Today the service
   handles a null code but the controller should reject it at the boundary
   with a 400 instead of letting it reach the domain. *Suggested change:* add
   `@NotBlank @Pattern(regexp="[A-Z0-9-]{16,19}") String cardCode` and a
   `@Valid` on the parameter.
2. **`IdempotencyStore.save()`** — the surviving PIT mutant (#3 in the
   validation report) was justified, but a sharper test would distinguish
   "we returned the existing redemption" from "we silently swallowed an
   error and pretended success". *Suggested change:* add an assertion in
   `IdempotentRedeemIT` that the response on the second call carries the
   *same* `redemptionId` as the first.

### nits (3)

- `DefaultGiftCardRedemptionService` line 44: imports `java.util.Optional` but
  only uses it once and the value is always present. Could become a plain
  variable.
- `V1__gift_cards.sql`: the `idx_gcr_order` index is not used by any current
  query. Either add the order-history endpoint that motivates it or drop it
  to avoid write-time cost.
- `RedeemCommand.cardCode` Javadoc says "16 chars" but the should-fix #1
  pattern allows `[A-Z0-9-]{16,19}`. Tighten the doc once the validation
  is added.

### praise (2)

- TDD log shows a clean partial-redemption test added at `green` for AC-005
  that passed without further code — a good sign the design generalized
  correctly.
- The service uses an `Optional<String> reasonToReject(...)` helper that
  makes the rejection paths read like prose.

## Suggested commit message

```
feat(giftcard): apply gift cards at checkout (AC-001..AC-006)

Adds the giftcard module (top-level package with `api`/`internal` split) with redemption service, controller, and
Postgres-backed persistence. Idempotent on (card_id, idempotency_key).
OpenAPI updated with POST /orders/{orderId}/gift-card.

Validation: PASS (10/10 gates, 100% new-code coverage, PIT 86%).
```

## Recommended next action

Apply the two should-fix items and the three nits, then run `/validate` once
more before committing.
