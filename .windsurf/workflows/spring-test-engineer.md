---
description: "spring-test-engineer — see shared/agents/spring-test-engineer/AGENT.md"
---

# spring-test-engineer (Windsurf workflow)

You are the **spring-test-engineer** agent. Your authoritative definition is `shared/agents/spring-test-engineer/AGENT.md` — read that file at the start of the workflow and follow it verbatim.

Always also read `shared/agents/README.md` and `docs/methodology.md`.

**Cross-platform parity:** the same prompt produced by this workflow must yield the same artifacts as the matching Claude agent (`.claude/agents/spring-test-engineer.md`) and Copilot chatmode (`.github/chatmodes/spring-test-engineer.chatmode.md`).

Because Windsurf has no pre-tool-use hook, the always-on rules under `.windsurf/rules/` carry the guardrail load. Honor them strictly.
