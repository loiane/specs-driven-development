# Greenfield example: gift-card-checkout

A new Spring Boot 4 service. Demonstrates the full happy-path flow.

## Project layout

```
greenfield/
├── pom.xml                                  # wired to the harness
├── checkstyle.xml                           # minimal config
├── src/
│   ├── main/java/com/example/checkout/
│   │   ├── CheckoutApplication.java         # @SpringBootApplication
│   │   ├── giftcard/                        # one module (top-level package)
│   │   │   ├── api/                         # public API package
│   │   │   └── internal/                    # private impl (ArchUnit-enforced)
│   │   └── shared/
│   └── main/resources/
│       ├── application.yaml
│       ├── db/migration/V1__init.sql
│       └── openapi/openapi.yaml
│   └── test/java/com/example/checkout/
│       ├── ArchitectureTests.java           # ArchUnit boundary + cycle rules
│       └── giftcard/...
└── .specs/
    └── 2025-01-15-gift-card-checkout/
        ├── 01-spec.md
        ├── 02-spec-review.md
        ├── 03-design.md
        ├── 04-tasks.md
        ├── 05-implementation-log.md
        ├── 06-test-plan.md
        ├── 07-validation-report.md
        ├── 07a-traceability.md
        ├── 08-code-review.md
        ├── adr/
        │   └── ADR-001-archunit-for-module-boundaries.md
        └── .tdd-state.json
```

## How to read this example

The interesting files are under `.specs/2025-01-15-gift-card-checkout/`. Read
them in order:

1. [`01-spec.md`](./.specs/2025-01-15-gift-card-checkout/01-spec.md) — what the
   user typed at `/spec` and what the spec author produced.
2. [`02-spec-review.md`](./.specs/2025-01-15-gift-card-checkout/02-spec-review.md) — the
   review checklist verdict.
3. [`03-design.md`](./.specs/2025-01-15-gift-card-checkout/03-design.md) — module
   boundaries, REST contract, persistence, error model.
4. [`04-tasks.md`](./.specs/2025-01-15-gift-card-checkout/04-tasks.md) — three
   tasks, each tied to ACs.
5. [`05-implementation-log.md`](./.specs/2025-01-15-gift-card-checkout/05-implementation-log.md)
   — the four TDD blocks per task, with failing-test excerpts.
6. [`07-validation-report.md`](./.specs/2025-01-15-gift-card-checkout/07-validation-report.md)
   — the harness verdict.
7. [`08-code-review.md`](./.specs/2025-01-15-gift-card-checkout/08-code-review.md)
   — the pre-commit review.

The Java source files are abbreviated; the methodology output is the focus.
