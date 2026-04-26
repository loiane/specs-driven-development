---
description: "Run /ship — see shared/commands/ship.md for the authoritative spec."
---

# /ship (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/ship.md`](../../shared/commands/ship.md). Read it now and follow it step-by-step.

**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/ship.md`) and Windsurf workflow (`.windsurf/workflows/ship.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
