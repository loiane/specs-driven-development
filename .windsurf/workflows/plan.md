---
description: Run /plan — see .windsurf/workflows/plan.md for the authoritative spec.
---
# /plan

**Phase:** 3 — plan
**Owning agent:** `.windsurf/workflows/spring-architect.md`
**Skills used:** `spring-task-decomposition`, `spring-boot-4-conventions`, `openapi-contract-first`, `flyway-or-liquibase-detection`, `archunit-rules`, `adr-authoring`, `performance-optimization`

## Purpose
Translate a `PASS`-verdict spec into a design (`03-design.md`) and a task list (`04-tasks.md`), then initialize `.tdd-state.json`.

## Inputs
- `<feature-id>`.

## Reads
- `01-spec.md`, `02-spec-review.md` (verdict must be `PASS`).
- `.specs/_stack.json`.
- `.windsurf/templates/03-design.md`, `.windsurf/templates/04-tasks.md`, `.windsurf/templates/10-adr.md`.
- All design/architecture skills above.

## Writes
- `.specs/<feature-id>/03-design.md`
- `.specs/<feature-id>/04-tasks.md`
- `.specs/<feature-id>/.tdd-state.json` (initial: no `active_task`, every task `phase: "pending"`)
- `.specs/<feature-id>/adr/ADR-NNN-*.md` for any architecturally significant decision.

## Process
1. Refuse if `02-spec-review.md` is missing or its verdict is not `PASS`.
2. Refuse if `01-spec.md` still has any `Q-NNN`.
3. Produce `03-design.md`: module map, public API, REST contract sketch (or full OpenAPI), data model, migration plan (Flyway/Liquibase per `_stack.json`), error model, observability, security touch points, ArchUnit rule additions.
4. For each architecturally-significant choice, write an ADR.
5. Decompose into tasks `T-001`, `T-002`, ... Each task must list:
   - `id`, `title`, `acs_covered: [AC-NNN, ...]`, `files_in_scope: [paths]`, `depends_on`, `estimated_phases: [red, green, refactor, simplify]`.
   - Tasks that touch `src/main/**` MUST list at least one file under `src/test/**` in `files_in_scope`.
6. Validate AC coverage: every AC from `01-spec.md` must appear in at least one task. If not, FAIL the plan and surface the gap.
7. Initialize `.tdd-state.json`:
   ```json
   { "active_task": null, "tasks": { "T-001": { "phase": "pending", "files_in_scope": [...], "acs_covered": [...] }, ... } }
   ```

## Refuse if
- Spec review verdict is not `PASS`.
- Any AC has no covering task.
- Any task touches `src/main/**` without a corresponding `src/test/**` file in scope.

## Done when
Design, tasks, ADRs, and `.tdd-state.json` are written. Point the user to `/build T-001`.
