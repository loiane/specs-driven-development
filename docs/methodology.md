# Methodology — Spec-Driven Development for Spring Boot 4

The toolkit organizes feature delivery into **seven phases**. Each phase has:

- a single **owner agent**,
- a numbered **markdown artifact** stored under `.specs/<feature-id>/`,
- an **entry contract** (what must already exist),
- an **exit contract** (what must be true to advance),
- and a **gate** that is enforced by hooks / rules / chatmode tool allowlists.

```
1. Specify  →  2. Review specs  →  3. Plan (design + tasks)  →
4. Implement (TDD)  →  5. Test  →  6. Validate  →  7. Code review  →  Commit
```

## Cross-cutting rule for phases 1–3: no assumptions

`spring-spec-author` and `spring-architect` operate under a strict **no-invention policy** during specify, spec-review, design, and tasks:

- **Never guess.** Acceptance criteria, business rules, edge cases, field names, defaults, error semantics, SLAs, security constraints, integrations, and NFRs only enter an artifact if they appear in the source ticket, the conversation, or the existing codebase.
- **Always log open questions.** Every uncertainty becomes a `Q-NNN` entry under `## Open Questions` on the active artifact, recording: the question, why it matters, what would need to be decided, and any candidate options identified — but **not** a chosen answer.
- **Always ask the user** before finalizing the artifact. Answers move to `## Resolved Questions` with the user's verbatim text and a timestamp.
- **No silent defaults.** Real decisions either come from the user or get an explicit ADR.
- **Phase-exit gate.** A phase cannot advance while `Q-NNN` items are unresolved, unless the user explicitly marks them `deferred` with a recorded rationale.
- **Implementation invariant.** `spring-implementer` and `spring-test-engineer` refuse to act on tasks whose source AC or design section still references an unresolved `Q-NNN`.

This is enforced by templates (`shared/templates/`), checklists (`shared/checklists/`), and the `block-progress-on-open-questions` hook.

## Phase 1 — Specify

**Owner:** `spring-spec-author`
**Artifact:** `01-spec.md`
**Skills:** `issue-tracker-ingestion`, `ears-spec-authoring`

Steps:

1. Ask the user whether the work originates from a Jira ticket, GitHub issue, Linear item, or other tracker.
2. Detect available MCP servers (`scripts/detect-stack.sh --mcp`) and pull the source ticket via the appropriate MCP (Atlassian/Jira, GitHub `mcp_io_github_*`, Linear, Azure Boards, …). Record the source URL/ID in `## Source`.
3. Draft `01-spec.md` from the template:
   - `## Source` (ticket link, snapshot)
   - `## Goal` (one paragraph)
   - `## Acceptance Criteria` (EARS-lite, IDs `AC-001`, `AC-002`, …)
   - `## Non-Goals`
   - `## Glossary`
   - `## Open Questions` (`Q-NNN`)
   - `## Resolved Questions`
4. Surface any `Q-NNN` to the user and capture answers.

**Exit contract:** every AC has an ID; no unresolved `Q-NNN`; source recorded.

## Phase 2 — Review specs

**Owner:** `spring-spec-author`
**Artifact:** `02-spec-review.md`
**Checklist:** `shared/checklists/spec-review.md`

Walks the spec against the spec-review checklist. Anything unclear becomes a new `Q-NNN` and bounces back to phase 1 for resolution before this phase exits.

**Exit contract:** review checklist all-green; sign-off line present.

## Phase 3 — Plan (design + tasks)

**Owner:** `spring-architect`
**Artifacts:** `03-design.md`, `04-tasks.md`
**Skills:** `spring-boot-4-conventions`, `spring-security-baseline`, `openapi-contract-first`, `flyway-or-liquibase-detection`, `adr-authoring`, `spring-task-decomposition`

`03-design.md` contains:

- Architecture overview + ADR links (MADR-style, stored under `.specs/<feature-id>/adr/`)
- Spring component map (controllers / services / repositories / events)
- Module boundaries (top-level packages with `internal` sub-packages enforced by ArchUnit)
- OpenAPI sketch (request/response shapes, status codes)
- Data model + migration strategy (Flyway or Liquibase, never both)
- Security posture
- Risks + rollback strategy
- `## Open Questions` / `## Resolved Questions`

`04-tasks.md` contains a numbered task list. Each task has:

```
### T-001: <short title>
- AC-IDs: AC-001, AC-002
- Test-IDs: T-001-T1 (slice), T-001-T2 (IT)
- Files in scope: src/main/java/.../X.java, src/test/java/.../XTest.java
- Dependencies: none | T-000
- Gates: unit, slice, IT (Testcontainers), coverage
- Rollback: revert commit; no schema change
- Notes: ...
```

Tasks are sized at roughly 1–4 hours. Cross-task tests live in phase 5.

**Exit contract:** every AC traced to ≥1 task; every task has Test-IDs and Files-in-scope; no unresolved `Q-NNN`.

## Phase 4 — Implement (TDD)

**Owner:** `spring-test-engineer` + `spring-implementer`
**Artifacts:** `05-implementation-log.md`, `.specs/<feature-id>/.tdd-state.json`
**Command:** `/build <task-id>`
**Skills:** `tdd-red-green-refactor`, `junit5-testcontainers-patterns`, `clarity-over-cleverness`

Strict **red → green → refactor** per task, orchestrated by `/build`:

1. **Red.** `spring-test-engineer` writes the smallest failing test(s) for the task's `Test-IDs`. Run them. They MUST fail for the expected reason. Append a red entry to `05-implementation-log.md` and update `.tdd-state.json`.
2. **Green.** `spring-implementer` writes the minimum production code to turn them green. Rerun. Append a green entry.
3. **Refactor + Simplify.** Refactor with the suite green; then `/code-simplify` automatically runs the clarity-over-cleverness pass. Rerun tests + `mvn -q verify` for the touched module. Append the refactor + simplify entries.

The `block-impl-without-failing-test` hook enforces the red-before-green invariant; production code edits are refused until a new test is observed failing.

## Phase 5 — Test (broaden + harden)

**Owner:** `spring-test-engineer`
**Artifact:** `06-test-plan.md`
**Skills:** `archunit-rules`, `openapi-contract-first`, `junit5-testcontainers-patterns`

Adds cross-cutting tests not tied to a single task:

- ArchUnit verification rules (boundaries, cycles, naming)
- OpenAPI contract tests
- Property-based tests where useful
- **Integration tests with Testcontainers are mandatory** when Testcontainers is detected (Failsafe-managed `*IT.java`). If absent, propose adding it (with an ADR) or fall back to `@DataJpaTest`/embedded slices and record the gap.

`06-test-plan.md` documents the consolidated suite map and rationale.

## Phase 6 — Validate

**Owner:** `spring-validator`
**Artifacts:** `07-validation-report.md`, `07a-traceability.md`
**Skills:** `harness-report-parsing`, `requirements-traceability`, `jacoco-coverage-policy`, `pit-mutation-tuning`

Runs `scripts/harness.sh` (same script as CI). Parses each layer's report, classifies failures (regression vs pre-existing baseline tracked in `.specs/_baseline.json`), and writes `07-validation-report.md`.

Builds the **requirements traceability matrix** in `07a-traceability.md`:

| AC-ID | Tasks | Tests (status) | Code symbols | Gates |
|---|---|---|---|---|

Any AC without a covering test, or any orphan test/code without an AC link, is flagged as a finding and blocks the phase.

## Phase 7 — Code review (pre-commit)

**Owner:** `spring-code-reviewer`
**Artifact:** `08-code-review.md`
**Skills:** `spring-code-review-rubric`, `clarity-over-cleverness`, `spring-security-baseline`

Reviews the diff against the spec, design, conventions, security baseline, and test quality (incl. mutation survivors). Findings are classified `blocker | major | minor | nit`, ending with an `approve | request-changes` verdict.

Commit is gated on **zero blockers/majors** or a documented waiver. Request-changes loops back to `spring-implementer` (or `spring-test-engineer`); the affected phases re-run and review repeats.

## Baselines (brownfield)

`.specs/_baseline.json` records pre-existing harness failures so brownfield projects are not blocked on day one. Validator and code-reviewer treat baseline failures as informational; only **regressions** (new failures introduced by the feature) block.

## Phase summary

| Phase | Artifact(s) | Owner | Gate |
|---|---|---|---|
| 1. Specify | `01-spec.md` | `spring-spec-author` | No `Q-NNN` unresolved |
| 2. Review specs | `02-spec-review.md` | `spring-spec-author` | Checklist green |
| 3. Plan | `03-design.md`, `04-tasks.md` | `spring-architect` | All AC traced; no `Q-NNN` |
| 4. Implement | `05-implementation-log.md` | `spring-test-engineer` + `spring-implementer` | Each task: red→green→refactor logged |
| 5. Test | `06-test-plan.md` | `spring-test-engineer` | Cross-cutting suite mapped |
| 6. Validate | `07-validation-report.md`, `07a-traceability.md` | `spring-validator` | Harness green; full traceability |
| 7. Code review | `08-code-review.md` | `spring-code-reviewer` | Zero blockers/majors |
