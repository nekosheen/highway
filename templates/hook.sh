#!/usr/bin/env bash
# highway-router.sh — PreToolUse hook for Claude Code model routing
# Installed by: highway install
# Docs: https://github.com/nekosheen/highway

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Only act on Task tool calls
if [ "$TOOL" != "Task" ]; then
  exit 0
fi

PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('prompt',''))" 2>/dev/null || echo "")
MODEL=$(echo "$INPUT"  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('model',''))" 2>/dev/null || echo "")

# If model is already set, nothing to do
if [ -n "$MODEL" ]; then
  exit 0
fi

# Classify the prompt by keyword heuristics
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

classify() {
  local p="$1"

  # Opus signals: architecture, strategy, security, system design
  if echo "$p" | grep -qE "(architect|design system|microservice|security review|threat model|trade.?off|migration strategy|scale|distributed|multi.service|long.term)"; then
    echo "opus"
    return
  fi

  # Haiku signals: lookups, searches, reads, status
  if echo "$p" | grep -qE "(find|search|list|grep|glob|look.?up|fetch|get|read|count|what (is|are|does)|show|display|check|status|diff|log)"; then
    echo "haiku"
    return
  fi

  # Default: sonnet
  echo "sonnet"
}

SUGGESTED=$(classify "$PROMPT_LOWER")

echo "Highway router: no model specified in this Task call. Based on the prompt, suggested model: \`$SUGGESTED\`. Apply this by setting model=\"$SUGGESTED\" in the Task invocation."

exit 0
