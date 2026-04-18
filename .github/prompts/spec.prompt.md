---
mode: agent
description: Run /specify — see shared/commands/specify.md for the authoritative spec.
tools: ['codebase', 'editFiles', 'search', 'runCommands', 'runTests']
model: GPT-5
---

# /specify (GitHub Copilot prompt wrapper)

Single source of truth: [`shared/commands/specify.md`](../../shared/commands/specify.md). Read it now.

## Behavior

1. Open `shared/commands/specify.md` and execute its Process step-by-step.
2. Adopt the persona and rules of [`shared/agents/spring-spec-author.md`](../../shared/agents/spring-spec-author.md) (Copilot chatmode wrapper at `.github/chatmodes/spring-spec-author.chatmode.md`).
3. Apply the path-scoped rules in `.github/instructions/*.instructions.md` automatically.
4. Honor every `Refuse if` clause and ask the user to resolve preconditions before proceeding.
5. Never edit this wrapper to change command behavior — edit the shared file.
