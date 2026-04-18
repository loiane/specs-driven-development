---
name: spring-code-review-rubric
description: Pre-commit code review rubric for Spring Boot 4 changes. Used by `spring-code-reviewer` to produce `08-code-review.md` before any commit. Covers traceability, architecture, Spring idioms, error handling, data access, security, test quality, clarity, and migration.
when_to_use:
  - Phase 7 (Code review) — `/review` command.
  - Pre-PR review on a brownfield repo where this toolkit is being adopted.
authoritative_references:
  - shared/templates/code-review.template.md
  - shared/skills/spring-boot-4-conventions/SKILL.md
  - shared/skills/spring-security-baseline/SKILL.md
  - shared/skills/clarity-over-cleverness/SKILL.md
---

# Spring code review rubric

## Severity ladder

- **blocker** — must fix before commit. (Security hole, broken behavior, gate-bypass.)
- **major** — must fix before commit OR document as ADR + waiver.
- **minor** — should fix; leave a note if not.
- **nit** — taste; mention once, don't insist.

## Ten sections

### 1. Traceability

- Every diff hunk maps to an `AC-NNN` and a `T-NNN`.
- Files-in-scope honored (no edits outside the task's declared paths).
- Any new public API has a test referencing the AC.

### 2. Architecture

- Module boundaries respected (no `internal` cross-imports).
- ArchUnit rules pass (see `archunit-rules`).
- Layering correct (no controller→repository skip).
- No new circular dependency.

### 3. Spring idioms

- Constructor injection only (`spring-boot-4-conventions`).
- Package layout is by feature/domain, not by layer (no top-level `controller`/`service`/`repository`/`model` packages).
- `@HttpExchange` / `RestClient` (no new `RestTemplate`).
- `@MockitoBean`, not `@MockBean`.
- No `@Autowired` on fields or constructors.
- No `@SpringBootTest` where a slice would do.
- **No Lombok** anywhere in the diff (any `lombok.*` import is a must-fix).

### 4. Error handling

- Exceptions translated at the controller boundary, not in the service.
- Single error envelope shape, documented in OpenAPI.
- No `catch (Exception e) { throw new RuntimeException(e); }`.
- Domain exceptions are checked or sealed, not raw `RuntimeException`.

### 5. Data access

- No N+1 queries (look for entity navigation in a loop).
- All list endpoints paginated.
- Migration script forward-only OR rollback documented.
- No raw SQL with string concatenation.
- Transactions on services, not controllers.

### 6. Security

- Apply `spring-security-baseline` rubric.
- No secrets in source.
- Input validation at boundary AND service.
- Sensitive logs masked.
- No new High/Critical CVE.

### 7. Test quality

- Tests fail for the right reason (re-read the red excerpt in `05-implementation-log.md`).
- One AC per test where possible.
- No `@Disabled` without `# DisabledReason`.
- No removed assertions.
- Coverage holds; new code ≥95%.
- Mutants in changed packages all killed (or ADR-justified).
- Testcontainers used where required by stack detection.

### 8. Clarity over cleverness

- Apply `clarity-over-cleverness` skill.
- Names match domain language from `01-spec.md` glossary.
- No dead code, no commented-out blocks.
- Public methods have a single responsibility.
- Method length ≤ 30 lines (guideline, not hard rule).

### 9. Migration / contract

- OpenAPI diff matches actual code (springdoc check).
- Breaking changes have an ADR.
- DB migration follows `flyway-or-liquibase-detection`.
- No edits to a previously-released migration script.

### 10. Performance

Apply `shared/skills/performance-optimization/SKILL.md`. Block on:

- Any controller method returning `List<T>` without pagination (`Pageable`).
- N+1 queries (entity navigation in a loop or stream).
- New external HTTP call without explicit connect/read/write timeouts.
- `@Cacheable` added without a TTL or a size cap.
- `@Transactional` wrapping an outbound HTTP call.
- `synchronized` block around an I/O call (pins virtual-thread carriers).
- Hikari `maximumPoolSize` change without a measurement artifact.
- A `Counter` used to record a duration (use `Timer` with histogram).
- A perf-labeled change without a profile, JMH result, or before/after metric in `05-implementation-log.md`.

## Findings table format

```markdown
| ID | Severity | Section | File | Line | Finding | Suggested fix |
|----|---------|---------|------|------|---------|---------------|
| F-001 | blocker | security | CheckoutController.java | 47 | `@CrossOrigin("*")` on a state-changing endpoint | restrict to allowed origins or remove |
| F-002 | minor | clarity | PriceCalculator.java | 23 | nested ternary `a ? b ? c : d : e` | extract two helper methods |
```

## Verdict

End with one of:

- ✅ **Approve** — no blockers; minors noted; safe to commit.
- ⚠️ **Approve with waivers** — blockers/majors waived via the listed ADRs; commit OK.
- ❌ **Request changes** — blockers exist, no waivers; commit blocked.
