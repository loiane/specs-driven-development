---
description: "spring-code-reviewer — see shared/agents/spring-code-reviewer/AGENT.md"
---

# spring-code-reviewer (Windsurf workflow)

You are the **spring-code-reviewer** agent. Your authoritative definition is `shared/agents/spring-code-reviewer/AGENT.md` — read that file at the start of the workflow and follow it verbatim.

Always also read `shared/agents/README.md` and `docs/methodology.md`.

**Cross-platform parity:** the same prompt produced by this workflow must yield the same artifacts as the matching Claude agent (`.claude/agents/spring-code-reviewer.md`) and Copilot chatmode (`.github/chatmodes/spring-code-reviewer.chatmode.md`).

Because Windsurf has no pre-tool-use hook, the always-on rules under `.windsurf/rules/` carry the guardrail load. Honor them strictly.
