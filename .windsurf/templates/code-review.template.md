# Code Review: <FEATURE-ID>

> Owner: `spring-code-reviewer` · Phase 7 · Skills: `spring-code-review-rubric`, `clarity-over-cleverness`, `spring-security-baseline`
>
> Pre-commit. The commit is gated on **zero blockers/majors** or a documented waiver.

## Inputs

- Spec: `01-spec.md`
- Design: `03-design.md`, ADRs under `adr/`
- Validation: `07-validation-report.md`, `07a-traceability.md`
- Diff: <git range>

## Rubric application

### 1. Spec / AC traceability

- [ ] Every AC mapped to test(s) (verified via `07a-traceability.md`).
- [ ] No orphan tests, no orphan code.

### 2. Architecture

- [ ] Layers respected (controller → service → repository).
- [ ] Module boundaries respected; no cross-module access bypassing the published API package (no `..internal..` imports across packages).

### 3. Spring idioms

- [ ] Constructor injection only (no field `@Autowired`).
- [ ] Package by feature/domain (no top-level `controller`/`service`/`repository`/`model` packages added).
- [ ] No Lombok (no `lombok.*` imports anywhere in the diff).
- [ ] `@Transactional` boundaries correct; no nested transactions accidental.
- [ ] No `@SpringBootTest` where a slice would suffice.

### 4. Error handling & API surface

- [ ] Errors map to a documented `code` and HTTP status.
- [ ] No raw `RuntimeException` thrown across boundaries.
- [ ] OpenAPI matches reality (verified by contract gate).

### 5. Data access

- [ ] No N+1 queries (verified by IT or by inspection).
- [ ] Pagination present where lists can grow.
- [ ] Migrations forward-only OR reversible with reason.

### 6. Security

- [ ] Inputs validated at controller boundary.
- [ ] No secrets in code or config.
- [ ] AuthZ enforced where AC requires.

### 7. Test quality

- [ ] Assertions are strong (no `assertNotNull` masquerading as a real check).
- [ ] No `Thread.sleep` in tests.
- [ ] Surviving mutants in changed packages are addressed or ADR-justified.
- [ ] No `@Disabled` without `# DisabledReason: <link>`.

### 8. Clarity over cleverness

- [ ] No needless indirection or single-use helpers (skill: `clarity-over-cleverness`).
- [ ] Standard library / Spring idioms preferred over bespoke abstractions.
- [ ] Names obvious; over-qualified names shortened.
- [ ] Early returns / guard clauses used to flatten nesting.

### 9. Migration & backwards compatibility

- [ ] Schema changes are backward-compatible OR an ADR documents the cut-over.
- [ ] Public API changes are additive OR documented as breaking.

## Findings

| ID | Severity | File:Line | Description | Suggested fix |
|---|---|---|---|---|
| F-001 | blocker | `X.java:42` | … | … |
| F-002 | major | `Y.java:13` | … | … |
| F-003 | minor | `Z.java:5` | … | … |
| F-004 | nit | `W.java:1` | … | … |

Severities:

- **blocker** — must be fixed before commit. No waivers.
- **major** — must be fixed OR explicitly waived with rationale (and an ADR if structural).
- **minor** — should be fixed; can be deferred with a follow-up issue ID.
- **nit** — author discretion.

## Waivers

- W-001 (against F-NNN): rationale: <text>; ADR: <link>; approved by user: <YYYY-MM-DD>

## Verdict

- [ ] **approve** — proceed to `/commit`
- [ ] **request-changes** — return to `spring-implementer` (or `spring-test-engineer`); rerun `/build`/`/test`/`/validate`/`/review` as needed.

Reviewer: `spring-code-reviewer`
Date: <YYYY-MM-DD>
Diff hash: <git-sha-range>
