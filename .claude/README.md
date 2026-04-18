# Claude Code wrappers

This folder contains Claude-Code-specific wrappers. The authoritative content lives in `shared/`.

## Structure

```
.claude/
├── README.md
├── settings.json              # global Claude Code settings (permissions, hooks)
├── agents/                    # one .md per agent — frontmatter + reference to shared/
├── skills/                    # one folder per skill — SKILL.md + reference
├── commands/                  # slash commands
└── hooks/                     # pre/post tool-use hook scripts
```

Each Claude agent / skill / command file is a **thin pointer** to `shared/`:
- frontmatter declares Claude-specific metadata (`tools`, `model`, etc.)
- body says "Read and follow `shared/<path>/SKILL.md` (or `AGENT.md`) verbatim".

This keeps Claude, Copilot, and Windsurf in sync — there is exactly one source of truth per concept.
