# Hooks: Claude Code vs Grok Build

Koumei ships the same shell scripts under `hooks/`. How they run depends on the CLI.

## Claude Code

- Config: `.claude/settings.json` (`hooks.PreToolUse` / `hooks.PostToolUse`)
- Scripts are invoked automatically when Claude Code loads the project
- Typical matchers: Write/Edit → `quality-gate.sh`, `auto-format.sh`, `notify-phase.sh`; all tools → `log-operation.sh`

No extra trust step is required beyond Claude Code's own permissions UI.

## Grok Build

- Grok may use `.claude/settings.json` **permissions** as a fallback
- **Native Grok hooks** are not that JSON file. They live under `.grok/hooks/` or `[[hooks.*]]` tables in `config.toml`
- Project hooks stay disabled until the folder is trusted:

```
/hooks-list     # see what this session loaded
/hooks-trust    # trust this project so hooks can run
/hooks-add hooks/   # optional: register the shared scripts
```

Until `/hooks-trust` succeeds, Grok will not execute `hooks/*.sh` even if they are present.

To run the same quality-gate / format / log scripts natively in Grok, copy or symlink them into `.grok/hooks/` (or `/hooks-add`) after trusting the folder. Leaving them only in `hooks/` + `.claude/settings.json` is enough for Claude Code.
