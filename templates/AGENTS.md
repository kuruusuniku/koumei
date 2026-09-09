# Agent instructions (Koumei)

This project uses the Koumei multi-agent workflow. Compatible with **Claude Code** and **Grok Build** (`grok` CLI).

- Team, models, and conventions: `.agents/TEAM.md`
- Role prompts: `.agents/*/CLAUDE.md` (keep the filename `CLAUDE.md`; both CLIs load it)
- Slash skills: `/koumei-start`, `/koumei-analyze`, `/koumei-design`, `/koumei-review`, `/koumei-implement`, `/koumei-status` (also `/koumei-design-ux`, `/koumei-design-tech`)
- Skills live in `.claude/skills/` (Claude Code + Grok compatibility discovery) and are mirrored to `.grok/skills/` (Grok-native discovery)

When running under Grok Build, follow `.agents/TEAM.md` → **Grok Build defaults**: spawn Grok subagents from the parent session, or run nested work with Bash `grok --prompt-file path --always-approve` / `grok -p "..."`.
