---
name: pit-mutation-tuning
description: Configure and interpret PIT mutation testing scoped to changed code. Use when adding the mutation gate to a project, when interpreting `mutations.xml`, or when tuning thresholds.
when_to_use:
  - Phase 5/6 — running `mvn -Ppit pitest:mutationCoverage` and analyzing results.
  - Adding mutation testing to a brownfield project (incremental scope to avoid 30-minute waits).
authoritative_references:
  - https://pitest.org/
  - https://github.com/hcoles/pitest
---

# PIT mutation tuning

## Why mutation testing

Coverage proves the code ran. **Mutation proves the test would have caught a real defect.** A mutant is a small change (negate a condition, return null, change `>` to `<=`); a "killed" mutant means a test failed; a "survived" mutant means your test suite is blind.

## Default configuration

```xml
<plugin>
    <groupId>org.pitest</groupId>
    <artifactId>pitest-maven</artifactId>
    <version>1.17.0</version>
    <configuration>
        <targetClasses>
            <param>com.example.shop.*</param>
        </targetClasses>
        <targetTests>
            <param>com.example.shop.*</param>
        </targetTests>
        <mutators>
            <mutator>STRONGER</mutator>
        </mutators>
        <outputFormats>
            <param>HTML</param>
            <param>XML</param>
        </outputFormats>
        <timestampedReports>false</timestampedReports>
        <features>
            <feature>+GIT(from[HEAD~1])</feature>     <!-- only changed files -->
        </features>
        <mutationThreshold>80</mutationThreshold>
        <coverageThreshold>90</coverageThreshold>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.pitest</groupId>
            <artifactId>pitest-junit5-plugin</artifactId>
            <version>1.2.1</version>
        </dependency>
    </dependencies>
</plugin>
```

## Scope: incremental, not full

Full PIT runs are slow. Always scope to changed code:

- Locally / in `/build` refactor phase: `+GIT(from[HEAD~1])`.
- In CI for PRs: `+GIT(from[origin/main])`.
- Nightly: full run, results posted to dashboard but not blocking.

## What to do with surviving mutants

For every survived mutant in changed packages:

1. Look at the mutated line and the mutation type (e.g. "negated conditional").
2. Write a test that would have failed under the mutation.
3. Re-run; the mutant should now be killed.
4. Log the new test in `06-test-plan.md`.

If a mutant is genuinely equivalent (impossible to kill — e.g. a defensive `if` that can never be false), suppress it via `@CoverageIgnore` on the **specific method**, with a comment explaining why. Track in `08-code-review.md` waivers.

## Common mutation types worth caring about

| Mutator | Example | What it tells you |
|---|---|---|
| `NegateConditionals` | `if (x > 0)` → `if (x <= 0)` | Boundary tests missing. |
| `ReturnVals` | `return x;` → `return null;` | Caller doesn't validate non-null. |
| `MathMutator` | `a + b` → `a - b` | Arithmetic untested with non-zero values. |
| `VoidMethodCalls` | removes a call | Side effect not asserted. |

## Reading `mutations.xml`

```xml
<mutation status="SURVIVED" detected="false">
  <sourceFile>PriceCalculator.java</sourceFile>
  <mutatedClass>com.example.shop.checkout.PriceCalculator</mutatedClass>
  <mutatedMethod>apply</mutatedMethod>
  <mutator>org.pitest.mutationtest.engine.gregor.mutators.NegateConditionalsMutator</mutator>
  <description>negated conditional</description>
  <lineNumber>42</lineNumber>
</mutation>
```

`spring-validator` parses this and lists every `SURVIVED` mutant in changed files in `07-validation-report.md`.

## Anti-patterns

- Lowering `mutationThreshold` to make the build green.
- Excluding entire packages because they're "hard to test".
- Marking equivalent mutants without a one-line justification.
- Running PIT against the whole codebase on every build.
