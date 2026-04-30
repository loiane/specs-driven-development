# Brownfield example: legacy-orders

A pre-existing Spring service the toolkit was dropped into. It compiles but
the harness is missing several layers, the migration tool isn't wired, and
test coverage is patchy. This example shows what `/onboard` produces and the
recommended retrofit path before any new feature work begins.

## Pretend project state

- Spring Boot 3.2 (needs upgrade to 4.x — out of scope for `/onboard`).
- Maven, single module, ~30k LoC under `src/main/java/com/legacy/orders/...`.
- One root package, no module boundaries.
- JUnit 5 present; **no Testcontainers**; **H2 in-memory** for IT (forbidden by the methodology when a real engine is detected in production config).
- `application.yaml` references `jdbc:postgresql://...` — i.e. **Postgres in prod**.
- No Flyway, no Liquibase: schema is hand-managed via DBA scripts (red flag).
- Spotless, Checkstyle, SpotBugs, JaCoCo, PIT all **absent** from `pom.xml`.
- ~480 unit tests, ~12 IT, line coverage unknown until baseline runs.

## What `/onboard` does

1. Runs `.github/scripts/detect-stack.sh`, writes `.specs/_stack.json`.
2. Detects `migration == "none"` despite Postgres in prod → flags as a
   high-priority retrofit (not fatal; `both` would be fatal).
3. Counts source/test → classifies as **brownfield**.
4. Runs `.github/scripts/harness.sh --baseline` to capture today's reality (passes
   what passes; missing layers reported as `skipped` not `fail`).
5. Writes [`.specs/_onboarding.md`](./.specs/_onboarding.md) with the recommended sequence.

## Recommended retrofit sequence (read the full report)

`/onboard` will tell the user, roughly:

1. **Add Flyway**, baseline against the current production schema, freeze
   schema-by-DBA.
2. **Wire the harness POM fragment**: Spotless, Checkstyle, SpotBugs,
   JaCoCo (start at the *baselined* coverage, not 90%; raise the floor each
   sprint). PIT off until coverage is at 80%.
3. **Replace H2 IT with Testcontainers Postgres** for tests that touch SQL.
4. **Introduce ArchUnit** with a single rule: no cycles. Ratchet additional
   once package boundaries are clearer.
5. Only after 1–4 are green do you run `/spec` for a new feature.

The point: the methodology never demands you fix a brownfield project to its
ideal state in one pass. It captures reality, then improves it deliberately.
