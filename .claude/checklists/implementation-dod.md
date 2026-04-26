# Definition of Done — per task (`/build <task-id>`)

A task is **done** only when ALL of the following are true.

## Red

- [ ] At least one new test exists with the task's `Test-IDs`.
- [ ] The new test(s) ran and **failed for the expected reason** (assertion mismatch, NPE, missing endpoint — not a compile error masked as a failure).
- [ ] A `red` entry was appended to `05-implementation-log.md` with the failing command and its output snippet.
- [ ] `.specs/<feature-id>/.tdd-state.json` was updated.

## Green

- [ ] Production code edits stayed within `Files in scope` for the task.
- [ ] The minimum production code was written to pass the test (no extra features, no speculative abstractions).
- [ ] All new test(s) now pass.
- [ ] A `green` entry was appended to `05-implementation-log.md`.

## Refactor + Simplify

- [ ] The full module suite (`mvn -q verify -pl <module>`) is green.
- [ ] `/code-simplify` ran (clarity-over-cleverness pass) and the suite is still green.
- [ ] `refactor` and `simplify` entries appended to `05-implementation-log.md`.

## Quality

- [ ] No `@Disabled` test introduced without a `# DisabledReason: <link>` comment.
- [ ] No assertion removed.
- [ ] No coverage threshold lowered.
- [ ] Spotless / Checkstyle clean on touched files.

## Traceability

- [ ] Every new test references its AC via `@DisplayName("AC-NNN: …")` or `@Tag("AC-NNN")`.
- [ ] The task entry in `04-tasks.md` is marked `done` with the implementing commit SHA.

## Forbidden

- [ ] No `git commit` was attempted; commits only happen after `/review` approves.
- [ ] No `mvn -DskipTests`, `-Dpit.skip`, `-Dcheckstyle.skip`, `--no-verify` was used.
