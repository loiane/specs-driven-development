# Tasks: <FEATURE-ID>

> Owner: `spring-architect` · Phase 3 · Template: `.github/templates/tasks.template.md`
>
> One task ≈ 1–4 hours. Each task has explicit Test-IDs, files in scope, and gates. Tasks are executed by `/build <task-id>`.

## Inputs

- `03-design.md` revision: <git-sha or timestamp>

## Task Index

| ID | Title | AC-IDs | Depends on | Gates |
|---|---|---|---|---|
| T-001 | … | AC-001 | — | unit, slice, IT, coverage |
| T-002 | … | AC-002, AC-003 | T-001 | unit, slice, IT, coverage |

## Tasks

### T-001: <short imperative title>

- **AC-IDs:** AC-001
- **Test-IDs:** T-001-T1 (slice — controller validation), T-001-T2 (IT — Testcontainers Postgres)
- **Files in scope:**
  - `src/main/java/<package>/<NewClass>.java`
  - `src/test/java/<package>/<NewClassTest>.java`
  - `src/test/java/<package>/<NewClassIT>.java`
- **Dependencies:** none
- **Gates to run after green:** `format`, `compile`, `archunit`, `unit`, `slice`, `it`, `coverage`
- **Rollback:** revert commit; no schema change.
- **Notes:** <anything that helps the implementer; never invents behavior>

### T-NNN: …

## Cross-cutting items (handled in Phase 5)

- ArchUnit verification rules
- OpenAPI contract test
- Property-based tests (where useful)

## Open Questions

- Q-001: …

## Resolved Questions

- (none yet)

## Sign-off

- [ ] Every AC from `01-spec.md` is covered by at least one task.
- [ ] Every task has Test-IDs and Files-in-scope.
- [ ] All `Q-NNN` resolved or deferred-with-rationale.
- [ ] Reviewed by user on <YYYY-MM-DD>.
