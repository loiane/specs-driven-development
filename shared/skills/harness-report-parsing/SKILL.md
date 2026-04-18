---
name: harness-report-parsing
description: Parse harness output (Surefire/Failsafe XML, JaCoCo XML, PIT XML, Checkstyle/SpotBugs XML, OpenAPI diff JSON, dependency-check JSON) into a single structured summary. Use when writing `07-validation-report.md` or when a CI run failed and the agent must explain why.
when_to_use:
  - Phase 6 (Validate) — `/validate` command runs the harness and parses every report.
  - Diagnosing a CI failure from log output.
authoritative_references:
  - https://maven.apache.org/surefire/maven-surefire-plugin/xsd/surefire-test-report.xsd
  - https://www.jacoco.org/jacoco/trunk/coverage/report.dtd
---

# Harness report parsing

## Input file map

| Layer | Path | Format |
|---|---|---|
| Spotless | `target/spotless/` (markers) | exit code |
| Checkstyle | `target/checkstyle-result.xml` | XML |
| SpotBugs | `target/spotbugsXml.xml` | XML |
| Error Prone | compiler stderr | text |
| ArchUnit | `target/surefire-reports/.../ArchitectureTest.xml` | Surefire XML |
| ArchUnit | `target/surefire-reports/.../ArchitectureTest.xml` | Surefire XML |
| Surefire (unit) | `target/surefire-reports/TEST-*.xml` | Surefire XML |
| Failsafe (IT) | `target/failsafe-reports/TEST-*.xml` | Surefire XML |
| JaCoCo | `target/site/jacoco/jacoco.xml` | JaCoCo XML |
| PIT | `target/pit-reports/mutations.xml` | PIT XML |
| OpenAPI diff | `target/openapi-diff.json` | JSON |
| Dependency-check | `target/dependency-check-report.json` | JSON |

## Output shape (`harness-summary.json`)

`scripts/harness.sh --report` emits a single JSON document consumed by `spring-validator`:

```json
{
  "git_sha": "abc1234",
  "started_at": "2026-04-18T10:30:00Z",
  "finished_at": "2026-04-18T10:38:42Z",
  "gates": {
    "format":   { "status": "pass" },
    "compile":  { "status": "pass" },
    "static":   { "status": "pass", "spotbugs": { "high": 0, "medium": 0 }, "checkstyle": { "violations": 0 } },
    "arch":     { "status": "pass" },
    "unit":     { "status": "pass", "tests": 412, "failures": 0, "errors": 0, "skipped": 2, "skipped_reasons": ["DisabledReason: SHOP-9 flaky"] },
    "it":       { "status": "pass", "tests": 47, "failures": 0 },
    "coverage": { "status": "pass", "line": 0.93, "branch": 0.91, "new_code_line": 0.97 },
    "mutation": { "status": "pass", "kill_rate": 0.84, "survived_in_changed": 0 },
    "contract": { "status": "pass", "breaking": 0, "non_breaking": 3 },
    "security": { "status": "pass", "high": 0, "critical": 0, "waivers": 1 }
  },
  "overall": "pass"
}
```

## Parsing rules

- A **missing report** for a layer the project has configured = `error`, not `pass`.
- A **report with parse errors** = `error`.
- A test marked `skipped` with no `# DisabledReason:` comment in source = `error` (enforced by Checkstyle rule `RegexpSinglelineJava` looking for `@Disabled` without preceding comment).

## Surefire/Failsafe XML quick recipe

```xpath
/testsuite/@tests        -> total
/testsuite/@failures     -> assertion failures
/testsuite/@errors       -> exceptions
/testsuite/@skipped      -> skipped
/testsuite/testcase[skipped]/@name  -> list skipped tests
```

## JaCoCo new-code calculation

1. `git diff --unified=0 origin/main...HEAD -- '*.java'` → list of `(file, line-range)`.
2. For each file, read `jacoco.xml` `<class name="...">/<sourcefilename>` matching.
3. Inside `<line nr="N" mi="X" ci="Y" mb="A" cb="B"/>`:
   - `mi` = missed instructions
   - `ci` = covered instructions
   - A line counts as "covered" if `ci > 0`. "Missed" if `mi > 0` and `ci == 0`.
4. New-code coverage = covered ÷ (covered + missed) over diff lines only.

## PIT mutants in changed packages

```xpath
/mutations/mutation[@status='SURVIVED' and contains(mutatedClass, 'changed.package')]
```

`changed.package` is derived by mapping diff file paths → fully qualified class names.

## Anti-patterns

- Emitting `pass` because the report file is empty (it's not — failures with 0 tests is a misconfiguration).
- Counting `skipped` as `pass`.
- Aggregating across modules without per-module breakdown.
- Hiding errors as warnings.
