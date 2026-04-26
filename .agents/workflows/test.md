---
description: "Run /test — see shared/commands/test.md for the authoritative spec."
---

# /test (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/test.md`](../../shared/commands/test.md). Read it now and follow it step-by-step.

2. Adopt the role described in `shared/agents/spring-test-engineer/AGENT.md`.
**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/test.md`) and Windsurf workflow (`.windsurf/workflows/test.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
