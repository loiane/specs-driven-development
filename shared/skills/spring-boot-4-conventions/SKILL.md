---
name: spring-boot-4-conventions
description: Spring Framework 7 / Spring Boot 4 idioms and defaults. Use when writing or reviewing controllers, services, configuration, HTTP clients, async/virtual-thread code, or anything touching Spring's programming model.
when_to_use:
  - Writing new Spring components (controllers, services, configuration).
  - Reviewing PRs against Spring 6.x patterns to bring them up to Spring 7 / Boot 4.
  - Choosing between RestTemplate / WebClient / RestClient / @HttpExchange.
  - Configuring virtual threads, AOT, or structured logging.
authoritative_references:
  - https://docs.spring.io/spring-boot/reference/index.html
  - https://docs.spring.io/spring-framework/reference/index.html
---

# Spring Framework 7 / Spring Boot 4 conventions

> Java 25 + Spring Framework 7 + Spring Boot 4. Prefer the most modern idiom unless an ADR explains otherwise.

## Defaults to apply

### Package layout — by feature, not by layer

Top-level packages are **bounded contexts / features**, not technical layers.
Inside a feature, split by visibility (`api` published, `internal` hidden), not
by `controller` / `service` / `repository`.

```
com.example.checkout
├── giftcard/                    # feature/domain — one package per bounded context
│   ├── api/                     # published surface (DTOs, service interfaces, events)
│   │   ├── GiftCardRedemptionService.java
│   │   ├── RedeemCommand.java
│   │   └── GiftCardRedeemed.java
│   └── internal/                # private impl (controller, service impl, JPA, mappers)
│       ├── GiftCardController.java
│       ├── GiftCardRedemptionServiceImpl.java
│       ├── GiftCardEntity.java
│       └── GiftCardJpaRepository.java
├── order/                       # another feature
│   ├── api/
│   └── internal/
└── shared/                      # cross-cutting: error envelope, security config, time
```

Forbidden layouts (do **not** create these):

```
com.example.checkout
├── controller/        ❌ by-layer
├── service/           ❌ by-layer
├── repository/        ❌ by-layer
└── model/             ❌ by-layer
```

Why:
- Features change together; layers don't. By-feature keeps the diff for one
  change inside one package.
- It makes the `..internal..` ArchUnit rule meaningful (one feature can't
  reach into another's internals).
- It maps 1:1 to the module boundaries enforced by `archunit-rules`.

Cross-feature interaction:
- Other features depend only on `<feature>.api`.
- Prefer events (`ApplicationEventPublisher`) for fire-and-forget integration.
- Direct dependencies between features are explicit and asserted by ArchUnit
  (e.g. `order` may depend on `giftcard.api`, never the reverse).

### Dependency injection

- **Constructor injection only.** No field `@Autowired`. No setter injection except where Spring forces it (e.g., a pre-existing framework callback).
- One `final` field per dependency. Write the constructor explicitly — **Lombok is forbidden** (see *No Lombok* below).

```java
@Service
public class CheckoutService {
    private final OrderRepository orders;
    private final GiftCardClient giftCards;

    public CheckoutService(OrderRepository orders, GiftCardClient giftCards) {
        this.orders = orders;
        this.giftCards = giftCards;
    }
}
```

### HTTP clients

- **Outbound HTTP:** prefer **`@HttpExchange` declarative clients** built on `RestClient`. Use `WebClient` only when the call is genuinely reactive end-to-end.
- Do **not** use `RestTemplate` in new code.
- Each external API gets its own client interface in the `infra` package.

```java
@HttpExchange(url = "/cards", accept = "application/json")
public interface GiftCardClient {
    @GetExchange("/{code}")
    GiftCard fetch(@PathVariable String code);
}
```

### Web layer

- Controllers are `@RestController`. Return DTO records, not entities.
- Use Java `record` for request/response DTOs.
- Validate input at the controller boundary with `@Valid`.
- Map exceptions via `@RestControllerAdvice` to a single, documented error envelope.

```java
public record ApplyGiftCardRequest(@NotBlank String code, @Min(0) int orderTotalCents) {}
public record ApplyGiftCardResponse(int redeemedCents, int newOrderTotalCents) {}
```

### Persistence

- Spring Data JPA is the default. Use `@Query` for non-trivial reads; never rely on derived queries longer than three predicates.
- Always paginate list endpoints (`Pageable`). Reject unbounded queries.
- Use `@ServiceConnection` with Testcontainers in tests instead of `application-test.yml` overrides.

### Virtual threads

- Spring Boot 4 enables virtual threads for the web server by default. Keep it on. Do not introduce custom `Executor`s that pin to platform threads without measuring.

### Configuration

- One `@ConfigurationProperties` record per bounded module. Validate with `@Validated`.
- No `@Value` for grouped settings. Use `@Value` only for ad-hoc single primitives.

```java
@ConfigurationProperties("app.giftcard")
@Validated
public record GiftCardProperties(@NotBlank String baseUrl, @Min(1) int timeoutMs) {}
```

### Observability

- Structured logging via `Logger` + key/value pairs (Boot 4 native `StructuredLoggingFormatter`).
- Metrics via `MeterRegistry`; one counter per business outcome (`gift_card.redeemed`, `gift_card.rejected`).

### AOT-friendly

- No reflection on application code.
- Beans are `@Component`, `@Service`, etc. at compile time. No runtime registration.
- Anything dynamic is registered via a `RuntimeHintsRegistrar` and noted in the design doc.

## Anti-patterns to flag in review

- Field injection (`@Autowired` on a field).
- Lombok in any form (`@Data`, `@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`, `@Slf4j`, `@SneakyThrows`, etc.) — see *No Lombok* below.
- Top-level packages named `controller`, `service`, `repository`, `model`, `dto`, `util` (by-layer layout) — use feature/domain packages instead (see *Package layout*).
- `RestTemplate` in new code.
- Returning entities from controllers.
- Untyped `Map<String, Object>` request/response bodies.
- Catching `Exception` then rethrowing `RuntimeException` with no message.
- `@SpringBootTest` for code that a slice test (`@WebMvcTest`, `@DataJpaTest`) can cover.

## Java 25 features to use freely

- Records and sealed types for DTOs and domain.
- Pattern matching for `switch`.
- Virtual threads (default).
- Sequenced collections.

## No Lombok

Lombok is **forbidden** in new code, including new modules added to brownfield repos.

Why:
- Java 25 records, accessors, and concise constructors cover the legitimate use cases.
- Lombok is a compile-time bytecode rewriter that interferes with AOT, code coverage, mutation testing, and static analysis.
- It hides constructor signatures, which makes constructor-injection review harder.

Replacements:

| Lombok | Use instead |
|---|---|
| `@Data`, `@Value`, `@Builder` on a DTO | Java `record` (with a static factory or compact constructor for validation) |
| `@Getter` / `@Setter` | Plain accessors; for immutable types, the record's auto-generated accessors |
| `@RequiredArgsConstructor` / `@AllArgsConstructor` | Write the constructor explicitly (one-time cost; clarifies dependency graph) |
| `@Slf4j` | `private static final Logger log = LoggerFactory.getLogger(MyClass.class);` |
| `@SneakyThrows` | Declare the checked exception or wrap it explicitly with a meaningful message |
| `@EqualsAndHashCode`, `@ToString` | Records get these for free; for non-records, write them or use `Objects.equals` / `Objects.hash` |

Enforcement:
- The `pom.xml` must not declare `org.projectlombok:lombok` as a dependency in new modules.
- Add an ArchUnit rule (see `archunit-rules` skill): `noClasses().should().dependOnClassesThat().resideInAPackage("lombok..")`.
- `spring-code-reviewer` flags any Lombok import as a **must-fix**.
