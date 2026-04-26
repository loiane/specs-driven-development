---
description: "Run /validate — see shared/commands/validate.md for the authoritative spec."
---

# /validate (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/validate.md`](../../shared/commands/validate.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-validator/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/validate.md`) and Windsurf workflow (`.windsurf/workflows/validate.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
