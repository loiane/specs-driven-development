---
mode: agent
description: Run /wire-harness — see shared/commands/wire-harness.md for the authoritative spec.
tools: ['codebase', 'editFiles', 'search', 'runCommands', 'runTests']
model: GPT-5
---

# /wire-harness (GitHub Copilot prompt wrapper)

Single source of truth: [`shared/commands/wire-harness.md`](../../shared/commands/wire-harness.md). Read it now.

## Behavior

1. Open `shared/commands/wire-harness.md` and execute its Process step-by-step.
2. Adopt the persona and rules of [`shared/agents/spring-onboarding/AGENT.md`](../../shared/agents/spring-onboarding/AGENT.md) (Copilot chatmode wrapper at `.github/chatmodes/spring-onboarding.chatmode.md`). `/wire-harness` is an onboarding-extension command and runs under the same agent.
3. Apply the path-scoped rules in `.github/instructions/*.instructions.md` automatically.
4. Honor every `Refuse if` clause and ask the user to resolve preconditions before proceeding.
5. Never edit this wrapper to change command behavior — edit the shared file.
