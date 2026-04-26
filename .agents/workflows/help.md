---
description: "Run /help — see shared/commands/help.md for the authoritative spec."
---

# /help (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/help.md`](../../shared/commands/help.md). Read it now and follow it step-by-step.

**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/help.md`) and Windsurf workflow (`.windsurf/workflows/help.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
