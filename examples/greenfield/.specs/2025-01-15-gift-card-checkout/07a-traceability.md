# Traceability: 2025-01-15-gift-card-checkout

Generated: 2025-01-22T14:31:09Z

| AC      | Title                          | Tests                                                                                                  | Production code                                                                 |
|---------|--------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| AC-001  | Apply a valid gift card        | `giftcard.internal.DefaultGiftCardRedemptionServiceTest`, `giftcard.internal.GiftCardRedemptionIT`, `giftcard.internal.GiftCardControllerTest`, `giftcard.internal.GiftCardContractTest` | `giftcard.internal.DefaultGiftCardRedemptionService`, `giftcard.internal.GiftCardController` |
| AC-002  | Reject unknown card            | `giftcard.internal.DefaultGiftCardRedemptionServiceRejectionTest`, `giftcard.internal.GiftCardControllerTest`                                                                          | `giftcard.internal.DefaultGiftCardRedemptionService`                            |
| AC-003  | Reject expired card            | `giftcard.internal.DefaultGiftCardRedemptionServiceRejectionTest`, `giftcard.internal.GiftCardControllerTest`                                                                          | `giftcard.internal.DefaultGiftCardRedemptionService`                            |
| AC-004  | Reject depleted card           | `giftcard.internal.DefaultGiftCardRedemptionServiceRejectionTest`, `giftcard.internal.GiftCardControllerTest`                                                                          | `giftcard.internal.DefaultGiftCardRedemptionService`                            |
| AC-005  | Partial redemption             | `giftcard.internal.DefaultGiftCardRedemptionServiceTest`, `giftcard.internal.GiftCardRedemptionIT`                                                                                     | `giftcard.internal.DefaultGiftCardRedemptionService`, `giftcard.internal.GiftCardEntity` |
| AC-006  | Idempotent retry               | `giftcard.internal.IdempotentRedeemIT`, `giftcard.internal.GiftCardControllerTest`                                                                                                     | `giftcard.internal.IdempotencyStore`                                             |

## Notes

- Every AC has at least one `@Tag("AC-NNN")` test.
- Production-code column derived heuristically from test imports; verified
  manually during `/review`.
