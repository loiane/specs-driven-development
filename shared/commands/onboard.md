# /onboard

**Phase:** 0 — bootstrap
**Owning agent:** `shared/agents/spring-onboarding.md`
**Skills used:** `brownfield-onboarding`, `maven-harness-pom`, `flyway-or-liquibase-detection`, `harness-report-parsing`, `archunit-rules`

## Purpose
Inspect the repository, classify it as greenfield or brownfield, capture a baseline harness run, and produce `.specs/_onboarding.md` so future commands know the stack.

## Inputs
None required. Optional argument: a path to constrain the scan (e.g. a module subdir in a multi-module build).

## Reads
- `pom.xml` (root and any submodules)
- `src/main/**`, `src/test/**` (counts only)
- `db/migration/**`, `db/changelog/**`
- Existing `.specs/` if any

## Writes
- `.specs/_onboarding.md`
- `.specs/_stack.json` (output of `scripts/detect-stack.sh`)
- `.specs/_baseline.json` (only if any test exists; output of `scripts/harness.sh --baseline`)

## Process
1. Run `scripts/detect-stack.sh > .specs/_stack.json`. Refuse to proceed if `migration == "both"`.
2. Count source/test files; classify:
   - **Greenfield** if no `src/main/java/**` or only the Spring Boot `Application.java`.
   - **Brownfield** otherwise.
3. If brownfield, run `scripts/harness.sh --baseline` and capture results. Do NOT attempt to fix failures.
4. Diff the project's POM against `shared/maven/parent-pom-fragment.xml`; list missing harness layers as Findings.
5. Write `.specs/_onboarding.md` covering: classification, stack JSON, baseline gate results, missing layers, recommended `/specify` starting point.

## Refuse if
- `migration == "both"` — fatal; ask the user to pick one.
- The repo is not a Maven project (no `pom.xml`).

## Done when
`.specs/_onboarding.md` exists and the user has been shown a one-paragraph summary plus the next recommended command.
