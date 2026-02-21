#!/usr/bin/env bash
# highway install — patches Claude Code global config with model routing
set -euo pipefail

HIGHWAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOKS_DIR="$CLAUDE_DIR/hooks"
HOOK_DEST="$HOOKS_DIR/highway-router.sh"

# ── Checks ────────────────────────────────────────────────────────────────────

if grep -q "highway:start" "$CLAUDE_MD" 2>/dev/null; then
  echo "⚠️  Highway routing is already installed in $CLAUDE_MD"
  echo "   Run 'highway uninstall' first to reinstall."
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "❌ python3 is required but not found."
  exit 1
fi

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR"
touch "$CLAUDE_MD"

echo "" >> "$CLAUDE_MD"
cat "$HIGHWAY_DIR/templates/routing-block.md" >> "$CLAUDE_MD"
echo "✅ Injected routing policy into $CLAUDE_MD"

# ── Hook script ───────────────────────────────────────────────────────────────

mkdir -p "$HOOKS_DIR"
cp "$HIGHWAY_DIR/templates/hook.sh" "$HOOK_DEST"
chmod +x "$HOOK_DEST"
echo "✅ Installed hook script at $HOOK_DEST"

# ── settings.json ─────────────────────────────────────────────────────────────

HOOK_ENTRY=$(cat <<EOF
{
  "matcher": "Task",
  "hooks": [
    {
      "type": "command",
      "command": "$HOOK_DEST"
    }
  ]
}
EOF
)

if [ ! -f "$SETTINGS" ]; then
  # Create fresh settings.json
  python3 - <<PYEOF
import json
entry = $HOOK_ENTRY
settings = {"hooks": {"PreToolUse": [entry]}}
with open("$SETTINGS", "w") as f:
    json.dump(settings, f, indent=2)
print("✅ Created $SETTINGS with highway hook")
PYEOF
else
  # Merge into existing settings.json
  python3 - <<PYEOF
import json, sys

entry = $HOOK_ENTRY

with open("$SETTINGS", "r") as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
pre = hooks.setdefault("PreToolUse", [])

# Avoid duplicates
for existing in pre:
    for h in existing.get("hooks", []):
        if "highway-router" in h.get("command", ""):
            print("⚠️  Highway hook already exists in $SETTINGS — skipping.")
            sys.exit(0)

pre.append(entry)

with open("$SETTINGS", "w") as f:
    json.dump(settings, f, indent=2)

print("✅ Merged highway hook into $SETTINGS")
PYEOF
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "🛣️  Highway installed. Claude Code will now route Task calls by model tier."
echo "   Run 'highway status' to verify."
