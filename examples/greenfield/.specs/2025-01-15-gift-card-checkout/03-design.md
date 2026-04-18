# Design: gift-card-checkout

## Module map (ArchUnit-enforced)

```
com.example.checkout
├── giftcard            (NEW)  ← this feature
│   ├── api             public: GiftCardRedemptionService, events
│   └── internal        package-private: persistence, hashing
├── order               (existing)  depends on: shared, giftcard.api
└── shared              (existing)  no inbound module deps
```

Each top-level package under `com.example.checkout` is a module. Boundaries
are enforced by ArchUnit (see the `archunit-rules` skill): the `..internal..`
sub-package of every module is private to that module, and there are no cycles
between top-level packages. `giftcard` is a new module; it exposes only
`GiftCardRedemptionService` and the `GiftCardRedeemed` domain event from its
`api` sub-package. The `order` module depends on `giftcard.api` to apply a
redemption during checkout; the dependency is unidirectional and asserted by
`ArchitectureTests`.

## Public API (Java)

```java
package com.example.checkout.giftcard.api;

public sealed interface GiftCardRedemptionResult {
    record Applied(UUID redemptionId, Money amountApplied, Money remainingBalance) implements GiftCardRedemptionResult {}
    record Rejected(String errorCode) implements GiftCardRedemptionResult {}  // gift_card.{unknown,expired,depleted}
}

public interface GiftCardRedemptionService {
    GiftCardRedemptionResult redeem(RedeemCommand cmd);
}

public record RedeemCommand(
    UUID orderId,
    String cardCode,           // 16 chars; never logged
    Money orderSubtotal,
    String idempotencyKey      // 24h window
) {}
```

## REST contract (excerpt — full spec at `src/main/resources/openapi/openapi.yaml`)

```yaml
paths:
  /orders/{orderId}/gift-card:
    post:
      summary: Apply a gift card to an order
      parameters:
        - name: orderId
          in: path
          required: true
          schema: { type: string, format: uuid }
        - name: Idempotency-Key
          in: header
          required: true
          schema: { type: string, minLength: 16 }
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/RedeemRequest' }
      responses:
        '200': { $ref: '#/components/responses/Applied' }
        '422': { $ref: '#/components/responses/Rejected' }
        '409': { description: Idempotency conflict on a different payload }
```

## Data model

```sql
-- Flyway: src/main/resources/db/migration/V1__gift_cards.sql
create table gift_card (
    id              uuid primary key,
    code_hash       bytea not null unique,         -- SHA-256(code || salt)
    initial_balance bigint not null,               -- minor units (cents)
    remaining_balance bigint not null,
    issued_at       timestamptz not null,
    expires_at      timestamptz not null,
    constraint gc_balance_nonneg check (remaining_balance >= 0)
);

create table gift_card_redemption (
    id               uuid primary key,
    gift_card_id     uuid not null references gift_card(id),
    order_id         uuid not null,
    amount_applied   bigint not null,
    idempotency_key  text not null,
    created_at       timestamptz not null default now(),
    constraint gcr_amount_pos check (amount_applied > 0),
    unique (gift_card_id, idempotency_key)         -- supports AC-006
);

create index idx_gcr_order on gift_card_redemption(order_id);
```

Migration tool: **Flyway** (per `_stack.json` detection). Liquibase is absent
and remains absent — no `both`.

## Error model

| Code                  | HTTP | When                                        |
|-----------------------|------|---------------------------------------------|
| `gift_card.unknown`   | 422  | Hash lookup misses                          |
| `gift_card.expired`   | 422  | `expires_at < now()`                        |
| `gift_card.depleted`  | 422  | `remaining_balance = 0`                     |
| `idempotency.conflict`| 409  | Same key, different payload (already-applied with different orderId) |

Errors flow through the existing `RFC 7807 ProblemDetail` mapper in `shared`.

## Observability

- Counters: `gift_card.redeem.success`, `gift_card.redeem.failure{reason}`.
- Log line on every attempt: `INFO giftcard.redemption order_id=… card_id=… result=… amount_applied=…`.
  Card code is never in the log.
- Trace span: `giftcard.redeem` wrapping the service call.

## Security baseline (per skill)

- Endpoint requires the existing `customer` Spring Security role.
- The gift card code is never logged, never returned in responses, never put
  in URL paths or query strings.
- The `code_hash` column has a unique index but the raw code is discarded after
  hashing inside `GiftCardCodeHasher`.
- OWASP Dependency Check is wired (already in parent POM).

## ArchUnit additions

```java
@ArchTest
static final ArchRule giftcardInternalIsHidden =
    noClasses().that().resideOutsideOfPackage("..giftcard.internal..")
        .should().dependOnClassesThat().resideInAPackage("..giftcard.internal..");

@ArchTest
static final ArchRule giftcardDoesNotDependOnOrder =
    noClasses().that().resideInAPackage("..giftcard..")
        .should().dependOnClassesThat().resideInAPackage("..order..");

@ArchTest
static final ArchRule noCyclesBetweenTopLevelPackages =
    slices().matching("com.example.checkout.(*)..").should().beFreeOfCycles();
```

## Risks

1. **Card code timing attack.** Hash comparison must be constant-time
   (already guaranteed by hash equality on bytes; lookup goes via hashed index).
2. **Concurrent redemption of the same card.** The `unique (card_id, idempotency_key)`
   constraint protects retries; for two distinct orders racing, we rely on
   row-level lock + `remaining_balance >= 0` check constraint.

ADRs: see [`adr/ADR-001-archunit-for-module-boundaries.md`](./adr/ADR-001-archunit-for-module-boundaries.md).
