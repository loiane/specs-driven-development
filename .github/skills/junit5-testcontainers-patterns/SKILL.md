---
name: junit5-testcontainers-patterns
description: JUnit 5 + Spring Boot 4 test slice patterns and Testcontainers integration test patterns with `@ServiceConnection`. Use when writing or reviewing any test, especially when choosing between unit / slice / integration scope.
when_to_use:
  - Phase 4 (red step of `/build`) — writing the failing test.
  - Phase 5 (Test) — adding cross-cutting suites.
  - Anywhere a `@SpringBootTest` could be replaced with a slice test.
authoritative_references:
  - https://docs.spring.io/spring-boot/reference/testing/index.html
  - https://java.testcontainers.org/
---

# JUnit 5 + Testcontainers patterns

## Choose the smallest scope that covers the AC

| AC type | Use |
|---|---|
| Pure logic (calculator, validator, mapper) | Plain JUnit 5, no Spring |
| Controller validation, status codes, JSON shape | `@WebMvcTest` |
| JPA query / mapping | `@DataJpaTest` + Testcontainers (`@ServiceConnection`) |
| End-to-end through HTTP, with DB / external | `@SpringBootTest(webEnvironment = RANDOM_PORT)` + Testcontainers |
| Cache, security filter chain, bean wiring | targeted slice (e.g. `@WebMvcTest` + `@Import`) |

**`@SpringBootTest` is a last resort.** If a slice test can cover it, use the slice.

## Naming + traceability

- **Every `@Test` and `@ParameterizedTest` method MUST carry `@DisplayName`.** No exceptions — write the display name *before* the test body so articulating it forces clarity about what the test verifies. (Project rule: `feedback_displayname_on_every_test.md`.)
- The full annotation block on every test method is **all three** lines, in this order:

  ```java
  @Test
  @Tag("AC-007")
  @DisplayName("AC-007: given expired gift card, when applied, then returns 4xx")
  void appliesExpiredGiftCard() { ... }
  ```

- Display-name format for AC-traced tests: `"<T-ID>: given <precondition>, when <action>, then <outcome>"`. Short BDD-style sentence is acceptable for utility/regression tests not tied to a specific AC.
- `@Tag("AC-NNN")` makes the test machine-readable for the traceability matrix.
- One AC per test method when feasible.
- The simplify phase audits every newly-authored or modified test in the diff for `@DisplayName` — that's the safety net if the red phase missed it.

## Testcontainers with `@ServiceConnection` (Spring Boot 4)

```java
@DataJpaTest
@Testcontainers
class GiftCardRepositoryTest {

    @Container @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine");

    @Autowired GiftCardRepository repo;

    @Test
    @DisplayName("AC-004: given a new gift card, when saved and reloaded, then balance is preserved")
    @Tag("AC-004")
    void persistsBalance() {
        var saved = repo.save(GiftCard.with(BigDecimal.valueOf(100)));
        assertThat(repo.findById(saved.id()).orElseThrow().balance())
            .isEqualByComparingTo("100");
    }
}
```

Key points:

- `@ServiceConnection` replaces `@DynamicPropertySource` boilerplate in Boot 3+.
- One container **per test class** (or static across the suite via a base class).
- Pin the image tag (`postgres:17-alpine`, never `postgres:latest`).
- For Kafka, RabbitMQ, Redis — same pattern, official Testcontainers module + `@ServiceConnection`.

## When Testcontainers is mandatory

If the repo declares any `org.testcontainers:*` dependency, the harness considers Testcontainers IT mandatory for any feature that touches:

- A repository implementation
- A `@RestController` whose handler reads/writes the database
- A migration script
- A message broker producer/consumer

Skipping is allowed only with an ADR (`adr/NNN-no-testcontainers-for-<reason>.md`).

## Slice test patterns

```java
@WebMvcTest(CheckoutController.class)
class CheckoutControllerTest {

    @Autowired MockMvc mvc;
    @MockitoBean CheckoutService service;

    @Test
    @DisplayName("AC-003: given unknown order id, when GET /{id}, then returns 404")
    @Tag("AC-003")
    void unknownOrder() throws Exception {
        when(service.applyGiftCard(any(), any())).thenThrow(OrderNotFound.class);
        mvc.perform(post("/checkout/{id}/gift-card", "missing")
                .contentType(APPLICATION_JSON)
                .content("""{"code":"ABC","orderTotalCents":1000}"""))
           .andExpect(status().isNotFound());
    }
}
```

Use Spring Boot 4's `@MockitoBean` (replaces deprecated `@MockBean`).

## Fixtures

- Prefer **builders** (`GiftCardFixtures.fullyRedeemed()`) over raw constructors.
- Fixtures live in `src/test/java/.../testsupport/`.
- No production code in test sources. No test code in production sources.

## Forbidden in tests

- `Thread.sleep` for synchronization → use Awaitility.
- Hard-coded host ports.
- Mocking the SUT.
- `@Disabled` without a `# DisabledReason: <ticket-or-ADR-link>` comment on the line above.
- Removing assertions to make a test pass.
- Catching `Exception` and asserting nothing.

## Spring MVC Test 7 — deprecated APIs (do not use)

| Deprecated | Replacement | Reason |
|---|---|---|
| `status().isUnprocessableEntity()` | `status().is(422)` | Removed in Spring MVC Test 7.0 |
| `new MappingJackson2HttpMessageConverter()` in `standaloneSetup` | Remove the `.setMessageConverters()` call entirely | `MappingJackson2HttpMessageConverter` is removed in Spring 7; `standaloneSetup` auto-registers Jackson from the classpath — no explicit converter needed |
| `@MockBean` | `@MockitoBean` | Deprecated in Spring Boot 4; import from `org.springframework.test.context.bean.override.mockito` |
