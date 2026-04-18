---
description: Run /spec-review — see shared/commands/spec-review.md for the authoritative spec.
argument-hint: see shared/commands/spec-review.md
agent: spring-spec-author
---

# /spec-review (Claude Code wrapper)

This file is a thin pointer. The single source of truth is
[`shared/commands/spec-review.md`](../../shared/commands/spec-review.md). Read it before acting.

## Behavior

1. Load `shared/commands/spec-review.md` and follow Process step-by-step.
2. Delegate to `shared/agents/spring-spec-author.md` (already wrapped at `.claude/agents/spring-spec-author.md`).
3. Honor every `Refuse if` clause; do not proceed if any precondition fails.
4. Respect the hooks under `.claude/hooks/` — they will block bypass attempts (skipped tests, edits outside files_in_scope, production code without a failing test, etc.).
5. Do not duplicate command logic here; if the spec needs to change, edit the shared file.
