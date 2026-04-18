---
description: Run /spec — see shared/commands/spec.md for the authoritative spec.
---

# /spec (Windsurf workflow wrapper)

Single source of truth: [`shared/commands/spec.md`](../../shared/commands/spec.md). Cascade must read it now.

## Behavior

1. Load `shared/commands/spec.md` and follow Process step-by-step.
2. Adopt the role described in [`shared/agents/spring-spec-author.md`](../../shared/agents/spring-spec-author.md).
3. The rules under `.windsurf/rules/*.md` apply automatically (always-on + glob-scoped). They cover the same ground as Claude's hooks: no skip flags, no production code without a failing test, no edits outside files_in_scope, no advancing past unresolved Q-NNN.
4. Honor every `Refuse if` clause.
5. Do not duplicate logic in this file; edit the shared spec instead.
