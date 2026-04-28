---
applyTo: "src/**/*.{ts,html,scss}"
description: "Frontend code guardrails for Angular implementation, testing, and accessibility."
---

# Frontend code guardrails (Angular)

These rules apply when a task includes files under `src/**`.

## Build-phase rules (TDD)

- Test-first: write/extend failing tests before implementing behavior.
- Edit only files listed in the active task's `Files in scope`.
- Never skip frontend tests to force green.
- Never remove assertions from existing tests.

## Angular implementation rules

- Prefer standalone components and typed interfaces/models.
- Keep smart/container logic separate from presentational components where practical.
- Avoid hardcoded API URLs in components; route all calls through services.
- Keep templates accessible: semantic buttons/inputs, labels, and keyboard-operable controls.

## Test rules

- Add/maintain component/service tests for new behavior.
- Every user-input validation rule needs a negative-path test.
- For optimistic-update flows, test both success and rollback paths.

## Validate/review rules

- During `/validate` and `/review`, never modify production code or tests.
- Missing frontend validation outputs (lint/test/build for changed UI scope) is an error.
- Any waiver must reference an ADR.
