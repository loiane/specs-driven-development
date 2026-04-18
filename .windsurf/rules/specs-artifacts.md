---
trigger: glob
globs: [".specs/**/*.md"]
description: "Spec artifact rule — no invention, stable IDs, phase ordering."
---

# Spec artifact rule

You are editing under `.specs/`. These artifacts ARE the contract between phases.

- Stable IDs (`AC-NNN`, `T-NNN`, `Q-NNN`, ADR `NNN-…`). Never renumber.
- `Q-NNN` move from `## Open Questions` to `## Resolved Questions` with answer + date — never deleted.
- ADR file names are immutable once committed.
- Never invent. If you lack info, append a `Q-NNN` and halt.
- Don't edit a higher-numbered artifact while a lower-numbered one has unresolved `Q-NNN` or `request-changes` verdict.

Apply skills: `shared/skills/ears-spec-authoring/SKILL.md`, `spring-task-decomposition/SKILL.md`, `requirements-traceability/SKILL.md`.
