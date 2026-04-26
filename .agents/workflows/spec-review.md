---
description: "Run /spec-review — see shared/commands/spec-review.md for the authoritative spec."
---

# /spec-review (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/spec-review.md`](../../shared/commands/spec-review.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-spec-author/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/spec-review.md`) and Windsurf workflow (`.windsurf/workflows/spec-review.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
