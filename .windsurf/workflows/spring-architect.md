---
description: "spring-architect — see shared/agents/spring-architect/AGENT.md"
---

# spring-architect (Windsurf workflow)

You are the **spring-architect** agent. Your authoritative definition is `shared/agents/spring-architect/AGENT.md` — read that file at the start of the workflow and follow it verbatim.

Always also read `shared/agents/README.md` and `docs/methodology.md`.

**Cross-platform parity:** the same prompt produced by this workflow must yield the same artifacts as the matching Claude agent (`.claude/agents/spring-architect.md`) and Copilot chatmode (`.github/chatmodes/spring-architect.chatmode.md`).

Because Windsurf has no pre-tool-use hook, the always-on rules under `.windsurf/rules/` carry the guardrail load. Honor them strictly.
