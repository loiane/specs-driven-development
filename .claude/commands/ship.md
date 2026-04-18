---
description: Run /ship — see shared/commands/ship.md for the authoritative spec.
argument-hint: see shared/commands/ship.md
agent: spring-code-reviewer
---

# /ship (Claude Code wrapper)

This file is a thin pointer. The single source of truth is
[`shared/commands/ship.md`](../../shared/commands/ship.md). Read it before acting.

## Behavior

1. Load `shared/commands/ship.md` and follow Process step-by-step.
2. Delegate to `shared/agents/spring-code-reviewer.md` (already wrapped at `.claude/agents/spring-code-reviewer.md`).
3. Honor every `Refuse if` clause; do not proceed if any precondition fails.
4. Respect the hooks under `.claude/hooks/` — they will block bypass attempts.
5. Do not duplicate command logic here; if the spec needs to change, edit the shared file.
