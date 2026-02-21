#!/usr/bin/env bash
# highway status — show current routing installation state
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_DEST="$CLAUDE_DIR/hooks/highway-router.sh"

echo "🛣️  Highway Status"
echo "─────────────────────────────────────────"

# CLAUDE.md
if grep -q "highway:start" "$CLAUDE_MD" 2>/dev/null; then
  echo "✅ CLAUDE.md routing block: installed ($CLAUDE_MD)"
else
  echo "❌ CLAUDE.md routing block: NOT installed"
fi

# Hook script
if [ -f "$HOOK_DEST" ]; then
  echo "✅ Hook script: installed ($HOOK_DEST)"
else
  echo "❌ Hook script: NOT installed"
fi

# settings.json
if [ -f "$SETTINGS" ] && grep -q "highway-router" "$SETTINGS" 2>/dev/null; then
  echo "✅ settings.json hook: registered ($SETTINGS)"
else
  echo "❌ settings.json hook: NOT registered"
fi

echo ""

# Show the routing table if installed
if grep -q "highway:start" "$CLAUDE_MD" 2>/dev/null; then
  echo "Routing table:"
  python3 - <<PYEOF
import re
with open("$CLAUDE_MD", "r") as f:
    content = f.read()
match = re.search(r'<!-- highway:start -->(.*?)<!-- highway:end -->', content, re.DOTALL)
if match:
    block = match.group(1).strip()
    # Print just the table lines
    for line in block.split("\n"):
        if "|" in line:
            print(" ", line)
PYEOF
fi
