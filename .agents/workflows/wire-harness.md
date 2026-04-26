---
description: "Run /wire-harness — see shared/commands/wire-harness.md for the authoritative spec."
---

# /wire-harness (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/wire-harness.md`](../../shared/commands/wire-harness.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-onboarding/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/wire-harness.md`) and Windsurf workflow (`.windsurf/workflows/wire-harness.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
