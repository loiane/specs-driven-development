# Test Plan: <FEATURE-ID>

> Owner: `spring-test-engineer` · Phase 5 · Template: `shared/templates/test-plan.template.md`

## Inputs

- `04-tasks.md` revision: <git-sha>
- `05-implementation-log.md` revision: <git-sha>
- Stack snapshot: Testcontainers <present|absent>; OpenAPI source <controllers|file>.

## Test inventory

| Test-ID | Type | File | AC-IDs | Owner task | Status |
|---|---|---|---|---|---|
| T-001-T1 | slice (`@WebMvcTest`) | `src/test/java/.../XTest.java` | AC-001 | T-001 | green |
| T-001-T2 | IT (Testcontainers Postgres) | `src/test/java/.../XIT.java` | AC-001 | T-001 | green |
| ARCH-001 | ArchUnit | `src/test/java/.../ArchitectureTest.java` | — | phase 5 | green |
| CONTRACT-001 | OpenAPI diff | `src/test/java/.../OpenApiContractTest.java` | AC-002 | phase 5 | green |
| PROP-001 | property-based (jqwik) | `src/test/java/.../PropertyTest.java` | AC-005 | phase 5 | green |

## Cross-cutting suites added in this phase

### Architecture (ArchUnit)

- Layers: controller → service → repository (no skips, no inversions)
- No field injection (`@Autowired` on fields banned)
- Entities live in `*.domain.model.*`
- Controllers must end in `Controller`
- No `..internal..` access across top-level packages; no cycles between top-level packages.

### Contract (OpenAPI)

- Source of truth: `<api/openapi.yaml | generated from controllers>`
- Diff tool: <openapi-diff plugin>
- Breaking changes are `blocker`.

### Integration tests (Testcontainers)

- Containers: Postgres (`@ServiceConnection`), <broker>
- Reuse: `withReuse(true)` enabled via `~/.testcontainers.properties`
- Fixed clock + deterministic IDs for reproducibility.

## Coverage strategy

- Per-package threshold: **90% line + branch** (hard floor); target **95–100%**.
- New code threshold: **95%** via incremental check.
- Excluded: generated code, configuration classes annotated `@ExcludeFromCoverage`.

## Mutation strategy

- Tool: PIT.
- Scope: packages touched by this feature.
- Surviving mutants: each is reviewed; either an additional test is added or an ADR explains why it is acceptable.

## Gaps + waivers

> If a project lacks Testcontainers, OpenAPI tooling, or PIT, document the gap here and link the ADR proposing how to address it.

- (none)

## Sign-off

- [ ] Every AC has at least one passing test.
- [ ] No `@Disabled` test without a `# DisabledReason: <link>` comment.
- [ ] Cross-cutting suites all green.
- [ ] Reviewed by user on <YYYY-MM-DD>.
