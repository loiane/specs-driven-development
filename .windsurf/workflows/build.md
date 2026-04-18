---
description: Run /build — see shared/commands/build.md for the authoritative spec.
---

# /build (Windsurf workflow wrapper)

Single source of truth: [`shared/commands/build.md`](../../shared/commands/build.md). Cascade must read it now.

## Behavior

1. Load `shared/commands/build.md` and follow Process step-by-step.
2. Adopt the role described in [`shared/agents/spring-implementer.md`](../../shared/agents/spring-implementer.md).
3. The rules under `.windsurf/rules/*.md` apply automatically (always-on + glob-scoped). They cover the same ground as Claude's hooks: no skip flags, no production code without a failing test, no edits outside files_in_scope, no advancing past unresolved Q-NNN.
4. Honor every `Refuse if` clause.
5. Do not duplicate logic in this file; edit the shared spec instead.
