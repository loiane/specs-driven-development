# Examples

This folder contains two end-to-end walkthroughs of the methodology. They are
**documentation, not runnable projects** — every artifact (spec, design, tasks,
implementation log, validation report) is a real file produced as if a human had
driven the agent through every command. Use these as a reference when you're
unsure what a given phase's output should look like.

## [`greenfield/`](./greenfield/README.md)

A fresh Spring Boot 4 / Spring Framework 7 service. Demonstrates a single
feature — `gift-card-checkout` — taken from a one-sentence intent through
`/spec` → `/spec-review` → `/plan` → `/build` → `/test` → `/validate` →
`/review`. Includes a `pom.xml` skeleton wired to the harness, a representative
Modulith-free module layout (top-level packages with `internal` sub-packages enforced by ArchUnit), and a complete `.specs/2025-01-15-gift-card-checkout/`
directory.

## [`brownfield/`](./brownfield/README.md)

A pre-existing legacy-ish Spring service with no harness, a missing
migration tool, and partial tests. Demonstrates `/onboard` discovering the
gaps, capturing a baseline, and producing `.specs/_onboarding.md` with the
recommended retrofit sequence (add Flyway, add Testcontainers, raise
coverage to floor before adding new features).

## What these examples do **not** include

- Runnable Java code in every file (they would bit-rot). Where Java appears
  it's illustrative; the structure and the .specs artifacts are the point.
- Full test suites. The implementation log shows representative test bodies
  and the failing-then-passing transcripts; full source is omitted to keep
  the toolkit small.
- Generated reports (`target/**`). The validation report quotes the gate
  results inline.
