---
description: Run /status — see shared/commands/status.md for the authoritative spec.
---

# /status (Windsurf workflow wrapper)

Single source of truth: [`shared/commands/status.md`](../../shared/commands/status.md). Cascade must read it now.

## Behavior

1. Load `shared/commands/status.md` and follow Process step-by-step.

3. The rules under `.windsurf/rules/*.md` apply automatically (always-on + glob-scoped). They cover the same ground as Claude's hooks: no skip flags, no production code without a failing test, no edits outside files_in_scope, no advancing past unresolved Q-NNN.
4. Honor every `Refuse if` clause.
5. Do not duplicate logic in this file; edit the shared spec instead.
