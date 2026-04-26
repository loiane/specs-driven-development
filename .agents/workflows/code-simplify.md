---
description: "Run /code-simplify — see shared/commands/code-simplify.md for the authoritative spec."
---

# /code-simplify (Antigravity workflow wrapper)

Single source of truth: [`shared/commands/code-simplify.md`](../../shared/commands/code-simplify.md). Read it now and follow it step-by-step.

**Cross-platform parity:** this workflow must produce the same artifacts as the matching Claude command (`.claude/commands/code-simplify.md`) and Windsurf workflow (`.windsurf/workflows/code-simplify.md`).

The rules under `.agents/rules/*.md` apply automatically (always-on + glob-scoped). Honor every `Refuse if` clause in the shared spec.

Do not duplicate logic in this file; edit the shared spec instead.
