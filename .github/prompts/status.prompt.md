---
mode: agent
description: Run /status — see shared/commands/status.md for the authoritative spec.


---

# /status (GitHub Copilot prompt wrapper)

Single source of truth: [`shared/commands/status.md`](../../shared/commands/status.md). Read it now.

## Behavior

1. Open `shared/commands/status.md` and execute its Process step-by-step.

3. Apply the path-scoped rules in `.github/instructions/*.instructions.md` automatically.
4. Honor every `Refuse if` clause and ask the user to resolve preconditions before proceeding.
5. Never edit this wrapper to change command behavior — edit the shared file.
