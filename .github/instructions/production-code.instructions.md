---
applyTo: "src/main/**/*.java"
description: "Production code guardrails — TDD discipline and Spring Boot 4 conventions."
---

# Production code guardrails

You are about to edit production Java code under `src/main/**`.

## Block: TDD precondition

Before writing or editing any line in `src/main/**`:

1. Read `.specs/<active-feature>/.tdd-state.json`.
2. Confirm `tasks[<active-task>].phase == "red"` AND `red_failure_excerpt` is non-empty.
3. Confirm the file path you are about to edit appears in `tasks[<active-task>].files_in_scope`.

If any check fails, **refuse the edit** and tell the user:

> "Cannot edit production code: no failing test for task `<task-id>`. Run `/build <task-id>` so the test-engineer writes the failing test first."

## Spring Boot 4 conventions

Follow `shared/skills/spring-boot-4-conventions/SKILL.md`:

- Constructor injection only.
- **Package by feature/domain, not by layer.** Top-level packages are bounded contexts (`giftcard`, `order`, …), each with `api` (published) and `internal` (private) sub-packages. No top-level `controller` / `service` / `repository` / `model` packages.
- `@HttpExchange` / `RestClient` (never `RestTemplate` in new code).
- Records for DTOs.
- `@RestControllerAdvice` for error mapping.
- Pagination on every list endpoint.
- `@ConfigurationProperties` records for grouped settings.
- **No Lombok.** No `@Data`, `@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`, `@Slf4j`, etc. Java records and explicit constructors replace them.
- **Never use fully-qualified type names inline.** Always add an `import` statement and use the simple class name. `new com.example.Product()` inside a method body is forbidden; use `new Product()` with a proper import.
- **Prefer enums over multiple related constants.** A set of `public static final String` values modelling a closed domain set (status, role, type, category) must be an `enum`. Single-purpose constants may remain `static final` fields.

## Architecture conventions

Follow `shared/skills/archunit-rules/SKILL.md`:

- Each top-level package is a module; cross-module access goes through its `api` sub-package only.
- Never `import` from another module's `internal` package — enforced by ArchUnit.
- No cycles between top-level packages.

## Security baseline

Follow `shared/skills/spring-security-baseline/SKILL.md`:

- Default-deny in `SecurityFilterChain`.
- Bean Validation on DTOs + service-layer invariant checks.
- Mask PII / secrets in logs.
- No `@CrossOrigin("*")` on state-changing endpoints.
