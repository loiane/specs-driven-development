# Test plan: gift-card-checkout

## Coverage matrix

| AC      | Unit                                                    | Slice / WebMvc                  | Integration (Testcontainers)      | Contract (OpenAPI)            |
|---------|---------------------------------------------------------|---------------------------------|-----------------------------------|-------------------------------|
| AC-001  | `appliesFullBalanceWhenCardCoversSubtotal`              | `controller_returns_200`        | `GiftCardRedemptionIT.fullCover`  | request/response 200 schema   |
| AC-002  | `rejectsUnknownCode`                                    | `controller_returns_422_unknown`| —                                 | 422 unknown error envelope    |
| AC-003  | `rejectsExpiredCard`                                    | `controller_returns_422_expired`| —                                 | 422 expired error envelope    |
| AC-004  | `rejectsDepletedCard`                                   | `controller_returns_422_depleted`| —                                | 422 depleted error envelope   |
| AC-005  | `appliesFullBalanceWhenCardDoesNotCover`                | —                               | `GiftCardRedemptionIT.partial`    | (covered transitively)        |
| AC-006  | —                                                       | —                               | `IdempotentRedeemIT.sameKeyTwice` | header presence in spec       |

## Test types in use

- **Unit**: pure JUnit 5 with a stub repository; runs in <50ms each.
- **Slice**: `@WebMvcTest(GiftCardController.class)` with `@MockBean` service.
- **Integration**: `@SpringBootTest` + `@Testcontainers` Postgres 16; Flyway
  applies migrations on container start.
- **Contract**: swagger-request-validator wired into MockMvc to fail any
  divergence between live response and `openapi.yaml`.
- **Architecture**: `ArchitectureTests` (always-on) verifies module boundaries
  and the hidden-internal rule.

## Mutation testing

PIT runs under `mvn -Ppit`. Targets `com.example.checkout.giftcard.*`. Mutation
threshold 80%. Surviving mutants beyond that are listed in the validation
report and either killed or justified.

## Gap-NNN entries

*(empty — `/test --gap` after `/build T-004` produced no remaining gaps;
new-code coverage is 100% on this feature's lines.)*

## What is intentionally NOT tested

- The shared `ProblemDetail` mapper (covered by the platform's existing tests).
- Spring Security configuration (covered by the always-on
  `SecurityConfigurationTest` in `shared`).
- Liquibase paths (this project uses Flyway exclusively per `_stack.json`).
