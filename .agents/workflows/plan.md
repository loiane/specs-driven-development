---
description: "Run /plan — see shared/commands/plan.md for the authoritative spec."
---

# /plan (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/plan.md`](../../shared/commands/plan.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-architect/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/plan.md`) and Windsurf workflow (`.windsurf/workflows/plan.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
