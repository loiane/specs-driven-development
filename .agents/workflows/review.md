---
description: "Run /review — see shared/commands/review.md for the authoritative spec."
---

# /review (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/review.md`](../../shared/commands/review.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-code-reviewer/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/review.md`) and Windsurf workflow (`.windsurf/workflows/review.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
