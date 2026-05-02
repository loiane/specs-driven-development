---
marp: true
title: Spec-Driven Development in Practice
paginate: true
size: 16:9
---

# Spec-Driven Development in Practice

From AI-assisted coding to verifiable software delivery.

- Repository: specs-driven-development
- Audience: Engineering teams and tech leads

---

# Why This Exists

AI can generate code quickly, but teams still struggle with:

- Inconsistent outputs
- Assumption drift
- Weak traceability
- Uneven quality gates

This repo addresses those gaps with a structured, phase-based workflow.

---

# Core Idea

A deterministic delivery model:

- Explicit phase ownership
- Stable artifacts per phase
- TDD enforcement during build
- Validation and review gates before commit

Outcome: faster iteration with stronger reliability.

---

# Workflow Overview

1. Specify
2. Review specs
3. Plan (design and tasks)
4. Implement (TDD)
5. Test
6. Validate
7. Code review

Reference: docs/methodology.md

---

# Artifact Contract

Every phase produces a concrete artifact under `.specs/<feature-id>/`.

Examples:

- `01-spec.md`
- `03-design.md`
- `04-tasks.md`
- `07-validation-report.md`
- `08-code-review.md`

Reference: docs/artifact-contract.md

---

# Agent Roles

Specialized roles improve focus and accountability:

- Spec author
- Architect
- Test engineer
- Implementer
- Validator
- Code reviewer

Each role has constraints and handoff rules.

---

# Guardrails That Matter

Non-negotiable rules include:

- No silent defaults in specs and design
- Red -> green -> refactor discipline
- No skip flags for quality gates
- No code changes in validate/review phases
- Human decision checkpoints for high-risk actions

---

# Harness and Quality Gates

The harness validates multiple layers, including:

- Formatting and linting
- Compile and static analysis
- Architecture checks
- Unit and integration tests
- Coverage and mutation
- API contract checks
- Security checks

Reference: docs/harness-principles.md

---

# Traceability

This repository enforces traceability across:

- Acceptance criteria
- Tasks
- Tests
- Code changes
- Validation outcomes

Result: less ambiguity, easier audits, and safer releases.

---

# Demo Plan (8-10 min)

1. Start with a feature request
2. Draft `01-spec.md` with open questions
3. Show task decomposition in `04-tasks.md`
4. Show TDD red to green on one task
5. Show validation and review artifacts
6. End at explicit human approval point

---

# Adoption Plan

Start small:

1. Pick one medium feature
2. Run the full workflow end-to-end
3. Measure cycle time and defect rate
4. Retrospective and adjust team conventions

---

# Risks and Mitigations

Common concerns:

- "This feels slower"
- "Too much process"
- "Hard for brownfield"

Mitigations:

- Pilot with one feature
- Baseline and ratchet quality incrementally
- Keep artifacts concise and practical

---

# Call to Action

Run a one-sprint pilot:

- One feature
- One owner
- Full phase coverage
- Evidence-driven review

If the pilot reduces rework and improves confidence, scale it.
