---
mode: agent
description: Run /validate — see shared/commands/validate.md for the authoritative spec.
tools: ['codebase', 'editFiles', 'search', 'runCommands', 'runTests']
model: GPT-5
---

# /validate (GitHub Copilot prompt wrapper)

Single source of truth: [`shared/commands/validate.md`](../../shared/commands/validate.md). Read it now.

## Behavior

1. Open `shared/commands/validate.md` and execute its Process step-by-step.
2. Adopt the persona and rules of [`shared/agents/spring-validator.md`](../../shared/agents/spring-validator.md) (Copilot chatmode wrapper at `.github/chatmodes/spring-validator.chatmode.md`).
3. Apply the path-scoped rules in `.github/instructions/*.instructions.md` automatically.
4. Honor every `Refuse if` clause and ask the user to resolve preconditions before proceeding.
5. Never edit this wrapper to change command behavior — edit the shared file.
