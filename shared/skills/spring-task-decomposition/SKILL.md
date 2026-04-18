---
name: spring-task-decomposition
description: Decompose a Spring Boot 4 design into 1–4 hour TDD-shaped tasks with stable IDs, AC traceability, files-in-scope, and per-task gates. Use when authoring `04-tasks.md`.
when_to_use:
  - Phase 3 (Plan) — turning `03-design.md` + `01-spec.md` into an ordered task list.
  - Re-planning after a spec change.
authoritative_references:
  - shared/templates/tasks.template.md
  - shared/checklists/implementation-dod.md
---

# Spring task decomposition

## Sizing rule

Each task is **1–4 hours** for a competent engineer. If larger, split. If smaller than 30 minutes, fold into the previous task.

## Shape

A good task has all of:

1. **Stable ID** `T-NNN`. Never renumber.
2. **Linked AC-IDs** — what user-visible criteria this task moves forward.
3. **Test-IDs** — at least one (`T-NNN-T1`, `T-NNN-T2`).
4. **Files in scope** — every path the task is allowed to edit (production + tests). The hook enforces this.
5. **Dependencies** — `T-NNN` IDs that must be `done` first.
6. **Gates** — which harness layers run for this task (default: all that touch the changed packages).
7. **Rollback** — one sentence on how to revert if validation fails.

## Layering convention

Order tasks so that dependencies flow inward:

1. **Domain & contracts** — DTOs, value objects, OpenAPI snippet, migration script.
2. **Unit / slice tests + minimum impl** — one task per controller / service / repository concern.
3. **Integration tests** — Testcontainers, end-to-end through the controller.
4. **Cross-cutting** — ArchUnit rules, error envelope, observability.

## Worked example (excerpt from `04-tasks.md`)

```markdown
### T-001 — Add `apply-gift-card` request DTO and validation
- **AC-IDs:** AC-001, AC-003
- **Test-IDs:** T-001-T1 (rejects blank code), T-001-T2 (rejects negative total)
- **Files in scope:**
  - `src/main/java/com/example/shop/checkout/ApplyGiftCardRequest.java`
  - `src/test/java/com/example/shop/checkout/ApplyGiftCardRequestTest.java`
- **Dependencies:** none
- **Gates:** format, compile, unit
- **Rollback:** delete the two files; nothing else references them yet.

### T-002 — `POST /checkout/{orderId}/gift-card` controller stub
- **AC-IDs:** AC-001, AC-002, AC-003
- **Test-IDs:** T-002-T1 (404 when order missing), T-002-T2 (415 when wrong content-type), T-002-T3 (returns 200 happy-path with stub service)
- **Files in scope:** controller class + `@WebMvcTest`
- **Dependencies:** T-001
- **Gates:** format, compile, unit, slice
```

## Anti-patterns

- "Implement gift cards" — too big.
- A task with no `Test-IDs` — TDD impossible.
- A task whose `Files in scope` is `**/*` — hook will block edits.
- Two tasks editing the same file in parallel — serialize them.
- A task that says "refactor X" without an AC — refactors happen inside the refactor phase of `/build`, not as a standalone task.

## Self-check

- [ ] Every AC from `01-spec.md` is reachable from at least one task's `AC-IDs`.
- [ ] Every task has ≥1 `Test-ID`.
- [ ] Every task fits 1–4 hours.
- [ ] `Files in scope` is concrete paths, not glob patterns.
- [ ] Dependency DAG has no cycles.
