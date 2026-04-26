---
description: "Run /spec — see shared/commands/spec.md for the authoritative spec."
---

# /spec (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/spec.md`](../../shared/commands/spec.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-spec-author/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/spec.md`) and Windsurf workflow (`.windsurf/workflows/spec.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
