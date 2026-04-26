---
description: "Run /build — see shared/commands/build.md for the authoritative spec."
---

# /build (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/build.md`](../../shared/commands/build.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-implementer/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/build.md`) and Windsurf workflow (`.windsurf/workflows/build.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
