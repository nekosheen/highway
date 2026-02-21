#!/usr/bin/env bash
# highway uninstall — removes all highway patches from Claude Code config
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_DEST="$CLAUDE_DIR/hooks/highway-router.sh"

REMOVED=0

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

if grep -q "highway:start" "$CLAUDE_MD" 2>/dev/null; then
  # Remove the block between markers (including surrounding blank lines)
  python3 - <<PYEOF
with open("$CLAUDE_MD", "r") as f:
    content = f.read()

import re
# Remove highway block and any leading blank line before it
cleaned = re.sub(r'\n*<!-- highway:start -->.*?<!-- highway:end -->\n?', '', content, flags=re.DOTALL)
cleaned = cleaned.rstrip() + "\n"

with open("$CLAUDE_MD", "w") as f:
    f.write(cleaned)
PYEOF
  echo "✅ Removed routing block from $CLAUDE_MD"
  REMOVED=1
else
  echo "ℹ️  No highway block found in $CLAUDE_MD"
fi

# ── Hook script ───────────────────────────────────────────────────────────────

if [ -f "$HOOK_DEST" ]; then
  rm "$HOOK_DEST"
  echo "✅ Removed hook script at $HOOK_DEST"
  REMOVED=1
else
  echo "ℹ️  No hook script found at $HOOK_DEST"
fi

# ── settings.json ─────────────────────────────────────────────────────────────

if [ -f "$SETTINGS" ] && grep -q "highway-router" "$SETTINGS" 2>/dev/null; then
  python3 - <<PYEOF
import json

with open("$SETTINGS", "r") as f:
    settings = json.load(f)

pre = settings.get("hooks", {}).get("PreToolUse", [])
filtered = [
    entry for entry in pre
    if not any("highway-router" in h.get("command", "") for h in entry.get("hooks", []))
]
settings["hooks"]["PreToolUse"] = filtered

with open("$SETTINGS", "w") as f:
    json.dump(settings, f, indent=2)

print("✅ Removed highway hook from $SETTINGS")
PYEOF
  REMOVED=1
else
  echo "ℹ️  No highway hook found in $SETTINGS"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

if [ "$REMOVED" -eq 1 ]; then
  echo ""
  echo "🛣️  Highway uninstalled."
else
  echo ""
  echo "ℹ️  Nothing to uninstall — highway was not installed."
fi
