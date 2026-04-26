---
description: Run /wire-harness — see shared/commands/wire-harness.md for the authoritative spec.
---

# /wire-harness (Windsurf workflow wrapper)

Single source of truth: [`shared/commands/wire-harness.md`](../../shared/commands/wire-harness.md). Cascade must read it now.

## Behavior

1. Load `shared/commands/wire-harness.md` and follow Process step-by-step.
2. Adopt the role described in [`shared/agents/spring-onboarding.md`](../../shared/agents/spring-onboarding.md).
3. The rules under `.windsurf/rules/*.md` apply automatically (always-on + glob-scoped). They cover the same ground as Claude's hooks: no skip flags, no production code without a failing test, no edits outside files_in_scope, no advancing past unresolved Q-NNN.
4. Honor every `Refuse if` clause.
5. Do not duplicate logic in this file; edit the shared spec instead.
