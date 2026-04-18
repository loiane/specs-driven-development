---
mode: agent
description: Run /help — see shared/commands/help.md for the authoritative spec.


---

# /help (GitHub Copilot prompt wrapper)

Single source of truth: [`shared/commands/help.md`](../../shared/commands/help.md). Read it now.

## Behavior

1. Open `shared/commands/help.md` and execute its Process step-by-step.

3. Apply the path-scoped rules in `.github/instructions/*.instructions.md` automatically.
4. Honor every `Refuse if` clause and ask the user to resolve preconditions before proceeding.
5. Never edit this wrapper to change command behavior — edit the shared file.
