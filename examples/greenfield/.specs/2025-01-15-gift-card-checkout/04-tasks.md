# Tasks: gift-card-checkout

Tasks are executed one at a time via `/build T-NNN`. Each task collapses
red → green → refactor → simplify into a single command. Files outside the
declared `files_in_scope` are blocked by `.claude/hooks/enforce-files-in-scope.sh`
and the equivalent rules on Copilot/Windsurf.

## T-001: Persistence + hashing primitives

- **acs_covered**: `[]` (foundation; no AC fully closed yet)
- **depends_on**: none
- **files_in_scope**:
  - `src/main/resources/db/migration/V1__gift_cards.sql`
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardCodeHasher.java`
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardEntity.java`
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardRepository.java`
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardRedemptionEntity.java`
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardRedemptionRepository.java`
  - `src/test/java/com/example/checkout/giftcard/internal/GiftCardCodeHasherTest.java`
  - `src/test/java/com/example/checkout/giftcard/internal/GiftCardRepositoryIT.java`
- **estimated_phases**: `[red, green, refactor, simplify]`
- **notes**: Repository test uses Testcontainers Postgres (mandatory per stack
  detection — H2 is not allowed for IT here).

## T-002: Apply a valid card (AC-001, AC-005)

- **acs_covered**: `[AC-001, AC-005]`
- **depends_on**: `[T-001]`
- **files_in_scope**:
  - `src/main/java/com/example/checkout/giftcard/api/GiftCardRedemptionService.java`
  - `src/main/java/com/example/checkout/giftcard/api/GiftCardRedemptionResult.java`
  - `src/main/java/com/example/checkout/giftcard/api/RedeemCommand.java`
  - `src/main/java/com/example/checkout/giftcard/internal/DefaultGiftCardRedemptionService.java`
  - `src/test/java/com/example/checkout/giftcard/internal/DefaultGiftCardRedemptionServiceTest.java`
  - `src/test/java/com/example/checkout/giftcard/internal/GiftCardRedemptionIT.java`
- **estimated_phases**: `[red, green, refactor, simplify]`

## T-003: Reject paths + idempotency (AC-002, AC-003, AC-004, AC-006)

- **acs_covered**: `[AC-002, AC-003, AC-004, AC-006]`
- **depends_on**: `[T-002]`
- **files_in_scope**:
  - `src/main/java/com/example/checkout/giftcard/internal/DefaultGiftCardRedemptionService.java` (extend)
  - `src/main/java/com/example/checkout/giftcard/internal/IdempotencyStore.java`
  - `src/test/java/com/example/checkout/giftcard/internal/DefaultGiftCardRedemptionServiceRejectionTest.java`
  - `src/test/java/com/example/checkout/giftcard/internal/IdempotentRedeemIT.java`
- **estimated_phases**: `[red, green, refactor, simplify]`

## T-004: REST controller + OpenAPI

- **acs_covered**: `[AC-001, AC-002, AC-003, AC-004, AC-006]` (verified via WebMvc slice + contract test)
- **depends_on**: `[T-002, T-003]`
- **files_in_scope**:
  - `src/main/java/com/example/checkout/giftcard/internal/GiftCardController.java`
  - `src/main/resources/openapi/openapi.yaml` (add path)
  - `src/test/java/com/example/checkout/giftcard/internal/GiftCardControllerTest.java`
  - `src/test/java/com/example/checkout/giftcard/internal/GiftCardContractTest.java`
- **estimated_phases**: `[red, green, refactor, simplify]`

## AC coverage check

| AC      | Closing tasks      |
|---------|--------------------|
| AC-001  | T-002, T-004       |
| AC-002  | T-003, T-004       |
| AC-003  | T-003, T-004       |
| AC-004  | T-003, T-004       |
| AC-005  | T-002              |
| AC-006  | T-003, T-004       |

Every AC has at least one task. Plan is valid.
