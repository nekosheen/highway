# highway

> Model routing for Claude Code. Route tasks to `haiku`, `sonnet`, or `opus` automatically — saving up to 60% on token costs.

## How it works

Claude Code uses the `Task` tool to spawn sub-agents. `highway` teaches it to pick the right model for each task type by:

1. **Injecting a routing policy** into `~/.claude/CLAUDE.md` — Claude reads this and applies model selection on every `Task` call
2. **Installing a `PreToolUse` hook** — audits Task calls and flags any missing `model` parameter with a classification suggestion

| Task type | Model | Example |
|-----------|-------|---------|
| Lookup / search | `haiku` | "Find all TypeScript files that import from utils/" |
| Code / debug | `sonnet` | "Implement JWT authentication middleware" |
| Architecture / strategy | `opus` | "Design the microservices boundary for this monolith migration" |

## Install

### Via Homebrew (recommended)

```bash
brew tap nekosheen/highway
brew install highway
highway install
```

### Manual

```bash
git clone https://github.com/nekosheen/highway
cd highway
chmod +x bin/highway lib/*.sh templates/hook.sh
./bin/highway install
```

## Usage

```bash
highway install     # patch Claude Code config
highway status      # verify installation
highway uninstall   # remove all patches
highway version     # print version
```

## What gets installed

```
~/.claude/CLAUDE.md        ← routing policy block appended (between markers)
~/.claude/settings.json    ← PreToolUse hook registered
~/.claude/hooks/
  highway-router.sh        ← hook script that classifies Task prompts
```

All changes are **cleanly reversible** with `highway uninstall`.

## Requirements

- macOS or Linux
- `python3` (for JSON manipulation and hook script)
- Claude Code CLI

## The math

Routing ~50% of traffic to Haiku (at ~12x lower cost than Sonnet) can cut token spend by 40–60% depending on your workflow.

| Model | Input | Output |
|-------|-------|--------|
| Haiku 4.5 | $0.25 / 1M | $1.25 / 1M |
| Sonnet 4.6 | $3 / 1M | $15 / 1M |
| Opus 4.6 | $15 / 1M | $75 / 1M |

## License

MIT
