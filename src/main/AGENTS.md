# Production code guardrails

You are about to edit production Java code under `src/main/**`.

## TDD precondition (mandatory)

Before writing or editing **any** line in `src/main/**`:

1. Read `.specs/<active-feature>/.tdd-state.json`.
2. Confirm `tasks[<active-task>].phase == "red"` AND `red_failure_excerpt` is non-empty.
3. Confirm the file you are about to edit appears in `tasks[<active-task>].files_in_scope`.

If any check fails, **refuse the edit** and tell the user:

> "Cannot edit production code: no failing test for task `<task-id>`.
> Run `/build <task-id>` so the test-engineer writes the failing test first."

## Spring Boot 4 conventions

See `.claude/skills/spring-boot-4-conventions/SKILL.md` for the complete reference.

- **Constructor injection only** — never `@Autowired` on fields.
- **Package by feature/domain, not by layer.** Top-level packages are bounded contexts
  (`giftcard`, `order`, …), each with `api/` (published surface) and sub-packages for
  private impl (`model/`, `repository/`, `service/`). DTOs go in `api/dto/`. Domain
  exceptions go in `api/exception/`. No top-level `controller`, `service`, `repository`,
  `model`, `dto`, or `util` packages.
- `@HttpExchange` / `RestClient` for outbound HTTP (never `RestTemplate` in new code).
- Records for DTOs.
- `@RestControllerAdvice` for error mapping.
- Pagination on every list endpoint.
- `@ConfigurationProperties` records for grouped settings.
- **No Lombok.** No `@Data`, `@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`,
  `@Slf4j`, etc. Use Java records and explicit constructors instead.

## Architecture conventions

See `.claude/skills/archunit-rules/SKILL.md`.

- Each top-level package is a module; cross-module access goes through its `api/` sub-package only.
- Never `import` from another module's internal packages — enforced by ArchUnit.
- No cycles between top-level packages.

## Security baseline

See `.claude/skills/spring-security-baseline/SKILL.md`.

- Default-deny in `SecurityFilterChain`.
- Bean Validation on DTOs + service-layer invariant checks.
- Mask PII / secrets in logs.
- No `@CrossOrigin("*")` on state-changing endpoints.
