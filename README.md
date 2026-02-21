# highway

> Model routing for Claude Code. Route tasks to `haiku`, `sonnet`, or `opus` automatically — saving up to 60% on token costs.

## How it works

Claude Code uses the `Task` tool to spawn sub-agents. `highway` teaches it to pick the right model for each task type by:

1. **Injecting a routing policy** into `~/.claude/CLAUDE.md` — Claude reads this and applies model selection on every `Task` call
2. **Installing a `PreToolUse` hook** — audits every `Task` call and suggests the right model tier if one isn't set

| Task type | Model | Example |
|-----------|-------|---------|
| Lookup / search | `haiku` | "Find all TypeScript files that import from utils/" |
| Code / debug | `sonnet` | "Implement JWT authentication middleware" |
| Architecture / strategy | `opus` | "Design the microservices boundary for this monolith migration" |

## Install

Installation is two steps: **get the `highway` CLI**, then **run `highway install`** to patch Claude Code.

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/nekosheen/highway/main/install | bash
highway install
```

The CLI is installed to `~/.local/share/highway` and symlinked to `~/.local/bin/highway`.

> Make sure `~/.local/bin` is in your `$PATH`. Add `export PATH="$PATH:$HOME/.local/bin"` to your `~/.zshrc` or `~/.bashrc` if needed.

### Via Homebrew

> Note: if you have Google's `highway` SIMD library installed (`brew info highway`), use the one-liner above — Homebrew disallows same-name formulae from different taps.

```bash
brew tap nekosheen/highway
brew install nekosheen/highway/highway
highway install
```

### Manual

```bash
git clone https://github.com/nekosheen/highway
cd highway
chmod +x bin/highway lib/*.sh templates/hook.sh
bin/highway install   # patches Claude Code config
```

## Usage

```bash
highway install     # patch Claude Code global config (run once after install)
highway status      # verify all three install points are active
highway uninstall   # cleanly remove all patches
highway version     # print version
highway help        # show usage
```

## What gets patched

`highway install` modifies three files in `~/.claude/`:

```
~/.claude/CLAUDE.md              ← routing policy block injected (between markers)
~/.claude/settings.json          ← PreToolUse hook registered
~/.claude/hooks/
  highway-router.sh              ← classifier script: routes Task calls by prompt keywords
```

All changes are **cleanly reversible** with `highway uninstall`.

## Requirements

- macOS or Linux
- `python3`
- Claude Code CLI

## The math

Routing ~50% of traffic to Haiku (at ~12x lower cost than Sonnet) cuts token spend by 40–60% depending on your workflow.

| Model | Input | Output |
|-------|-------|--------|
| Haiku 4.5 | $0.25 / 1M | $1.25 / 1M |
| Sonnet 4.6 | $3 / 1M | $15 / 1M |
| Opus 4.6 | $15 / 1M | $75 / 1M |

## Releasing a new version

```bash
# 1. Bump VERSION in bin/highway
# 2. Commit and push
git tag vX.Y.Z && git push origin vX.Y.Z
gh release create vX.Y.Z

# 3. Get the new tarball SHA256
gh api repos/nekosheen/highway/tarball/vX.Y.Z > /tmp/hw.tar.gz
shasum -a 256 /tmp/hw.tar.gz

# 4. Update Formula/highway.rb with new version + sha256
# 5. Push updated formula to nekosheen/homebrew-highway
```

## License

MIT
