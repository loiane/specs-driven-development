---
description: "Run /status — see shared/commands/status.md for the authoritative spec."
---

# /status (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/status.md`](../../shared/commands/status.md). Read it now and follow it step-by-step.

**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/status.md`) and Windsurf workflow (`.windsurf/workflows/status.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
