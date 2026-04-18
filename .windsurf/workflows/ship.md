---
description: Run /ship — see shared/commands/ship.md for the authoritative spec.
---

# /ship (Windsurf workflow wrapper)

Single source of truth: [`shared/commands/ship.md`](../../shared/commands/ship.md). Cascade must read it now.

## Behavior

1. Load `shared/commands/ship.md` and follow Process step-by-step.
2. Adopt the role described in [`shared/agents/spring-code-reviewer.md`](../../shared/agents/spring-code-reviewer.md).
3. The rules under `.windsurf/rules/*.md` apply automatically (always-on + glob-scoped).
4. Honor every `Refuse if` clause.
5. Do not duplicate logic in this file; edit the shared spec instead.
