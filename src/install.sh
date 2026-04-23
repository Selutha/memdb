#!/usr/bin/env bash
set -euo pipefail

# install.sh: Install mem-cli, skills, and hooks for Claude Code
# Run from the src/ directory of the claude-mem project.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Installing claude-mem ==="
echo ""

# ---------------------------------------------------------------------------
# 1. Install mem-cli binary
# ---------------------------------------------------------------------------
echo "1. Installing mem-cli..."
mkdir -p "$CLAUDE_DIR/bin"
cp "$SCRIPT_DIR/bin/mem-cli" "$CLAUDE_DIR/bin/mem-cli"
chmod +x "$CLAUDE_DIR/bin/mem-cli"
echo "   -> $CLAUDE_DIR/bin/mem-cli"

# ---------------------------------------------------------------------------
# 2. Install skills
# ---------------------------------------------------------------------------
echo "2. Installing skills..."
for skill in memdb mem; do
    mkdir -p "$CLAUDE_DIR/skills/$skill"
    cp "$SCRIPT_DIR/skills/$skill/SKILL.md" "$CLAUDE_DIR/skills/$skill/SKILL.md"
    echo "   -> $CLAUDE_DIR/skills/$skill/SKILL.md"
done

# ---------------------------------------------------------------------------
# 3. Merge hooks into settings.json
# ---------------------------------------------------------------------------
echo "3. Configuring hooks..."

SETTINGS="$CLAUDE_DIR/settings.json"

# The hooks we need to add
HOOKS_JSON='{
  "PostToolUse": [
    {
      "matcher": "Bash|Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "$HOME/.claude/bin/mem-cli capture"
        }
      ]
    }
  ],
  "SessionStart": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "$HOME/.claude/bin/mem-cli session-start"
        }
      ]
    }
  ],
  "UserPromptSubmit": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "$HOME/.claude/bin/mem-cli prompt-search"
        }
      ]
    }
  ],
  "SessionEnd": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "$HOME/.claude/bin/mem-cli session-end"
        }
      ]
    }
  ]
}'

if [[ ! -f "$SETTINGS" ]]; then
    # No settings file — create one with just hooks
    echo "{\"hooks\": $HOOKS_JSON}" | jq '.' > "$SETTINGS"
    echo "   -> Created $SETTINGS with hooks"
else
    # Settings file exists — check if hooks already configured
    if jq -e '.hooks.PostToolUse' "$SETTINGS" > /dev/null 2>&1; then
        # Hooks key exists — check if our hooks are already there
        local_check="$(jq -r '.hooks.PostToolUse[]?.hooks[]?.command // empty' "$SETTINGS" | grep -c 'mem-cli' || true)"
        if [[ "$local_check" -gt 0 ]]; then
            echo "   -> Hooks already configured (skipping)"
        else
            # Merge our hooks with existing hooks
            jq --argjson new_hooks "$HOOKS_JSON" '
                .hooks = (
                    .hooks // {} |
                    to_entries + ($new_hooks | to_entries) |
                    group_by(.key) |
                    map({key: .[0].key, value: [.[] | .value[]] | flatten}) |
                    from_entries
                )
            ' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
            echo "   -> Merged hooks into existing $SETTINGS"
        fi
    else
        # No hooks key — add it
        jq --argjson new_hooks "$HOOKS_JSON" '.hooks = (.hooks // {} | . * $new_hooks)' \
            "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
        echo "   -> Added hooks to $SETTINGS"
    fi
fi

# ---------------------------------------------------------------------------
# 4. Verify
# ---------------------------------------------------------------------------
echo ""
echo "=== Verification ==="
if "$CLAUDE_DIR/bin/mem-cli" help > /dev/null 2>&1; then
    echo "mem-cli: OK"
else
    echo "mem-cli: FAILED — check $CLAUDE_DIR/bin/mem-cli"
    exit 1
fi

if [[ -f "$CLAUDE_DIR/skills/memdb/SKILL.md" ]] && [[ -f "$CLAUDE_DIR/skills/mem/SKILL.md" ]]; then
    echo "Skills:  OK (/memdb, /mem)"
else
    echo "Skills:  FAILED — check $CLAUDE_DIR/skills/"
    exit 1
fi

if jq -e '.hooks.PostToolUse' "$SETTINGS" > /dev/null 2>&1; then
    echo "Hooks:   OK"
else
    echo "Hooks:   FAILED — check $SETTINGS"
    exit 1
fi

echo ""
echo "=== Done ==="
echo "Start a Claude Code session and type /memdb to activate memory for a project."
echo "Use /mem search, /mem timeline, /mem detail to query."
