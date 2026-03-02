#!/usr/bin/env bash
# Life OS Starter — Setup Script (macOS / Linux)
# Usage: ./setup.sh [--root ~/Life\ Operating\ System] [--workspace ~/.craft-agent/workspaces/my-workspace]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "=== Life OS Starter Setup ==="
echo ""

# --- Parse args ---

LIFEOS_ROOT=""
WORKSPACE_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --root) LIFEOS_ROOT="$2"; shift 2 ;;
        --workspace) WORKSPACE_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# --- Prompt for paths if not provided ---

if [ -z "$LIFEOS_ROOT" ]; then
    DEFAULT="$HOME/Life Operating System"
    read -rp "Life OS root folder [$DEFAULT]: " LIFEOS_ROOT
    LIFEOS_ROOT="${LIFEOS_ROOT:-$DEFAULT}"
fi

if [ -z "$WORKSPACE_PATH" ]; then
    DEFAULT="$HOME/.craft-agent/workspaces/my-workspace"
    read -rp "Craft Agent workspace folder [$DEFAULT]: " WORKSPACE_PATH
    WORKSPACE_PATH="${WORKSPACE_PATH:-$DEFAULT}"
fi

# Resolve paths
LIFEOS_ROOT="$(cd "$(dirname "$LIFEOS_ROOT")" 2>/dev/null && pwd)/$(basename "$LIFEOS_ROOT")" || LIFEOS_ROOT="$LIFEOS_ROOT"
WORKSPACE_PATH="$(cd "$(dirname "$WORKSPACE_PATH")" 2>/dev/null && pwd)/$(basename "$WORKSPACE_PATH")" || WORKSPACE_PATH="$WORKSPACE_PATH"

echo ""
echo "Life OS root:  $LIFEOS_ROOT"
echo "Workspace:     $WORKSPACE_PATH"
echo ""

read -rp "Proceed? [Y/n] " confirm
if [ -n "$confirm" ] && [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    echo "Aborted."
    exit 1
fi

# --- Helper: copy with path replacement ---

SETUP_DATE=$(date +%Y-%m-%d)

copy_templated() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    sed -e "s|{{LIFEOS_ROOT}}|$LIFEOS_ROOT|g" \
        -e "s|{{SETUP_DATE}}|$SETUP_DATE|g" \
        "$src" > "$dest"
}

copy_plain() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
}

# --- Step 1: Create Life OS folder structure ---

echo ""
echo "[1/5] Creating Life OS folder structure..."

mkdir -p "$LIFEOS_ROOT/AI/Agents/Architect/System"
mkdir -p "$LIFEOS_ROOT/AI/Agents/Architect/Workflows"
mkdir -p "$LIFEOS_ROOT/AI/Agents/Architect/Tools/Templates"
mkdir -p "$LIFEOS_ROOT/AI/Agents/Architect/Tools/Scripts"
mkdir -p "$LIFEOS_ROOT/AI/Agents/Architect/Handover/Archive"
mkdir -p "$LIFEOS_ROOT/Second Brain"

# --- Step 2: Copy framework docs ---

echo "[2/5] Copying framework docs..."

copy_templated "$SCRIPT_DIR/framework/Life OS Framework.md" "$LIFEOS_ROOT/Life OS Framework.md"
copy_templated "$SCRIPT_DIR/framework/Agent Principles.md" "$LIFEOS_ROOT/Agent Principles.md"

# --- Step 3: Copy Architect agent + registry ---

echo "[3/5] Setting up Architect agent..."

copy_templated "$SCRIPT_DIR/agents/registry.json" "$LIFEOS_ROOT/AI/Agents/registry.json"
copy_templated "$SCRIPT_DIR/agents/Architect/System/README.md" "$LIFEOS_ROOT/AI/Agents/Architect/System/README.md"
copy_plain "$SCRIPT_DIR/agents/Architect/System/persona.md" "$LIFEOS_ROOT/AI/Agents/Architect/System/persona.md"
copy_plain "$SCRIPT_DIR/agents/Architect/System/responsibilities.md" "$LIFEOS_ROOT/AI/Agents/Architect/System/responsibilities.md"
copy_templated "$SCRIPT_DIR/agents/Architect/Workflows/create-agent.md" "$LIFEOS_ROOT/AI/Agents/Architect/Workflows/create-agent.md"
copy_templated "$SCRIPT_DIR/agents/Architect/Tools/Templates/agent-template.md" "$LIFEOS_ROOT/AI/Agents/Architect/Tools/Templates/agent-template.md"

# --- Step 4: Copy workspace files ---

echo "[4/5] Setting up Craft Agent workspace..."

if [ ! -d "$WORKSPACE_PATH" ]; then
    echo "  Workspace folder doesn't exist yet. Creating it..."
    mkdir -p "$WORKSPACE_PATH"
fi

# Skills
for skill in start handoff new-agent architect; do
    mkdir -p "$WORKSPACE_PATH/skills/$skill"
    copy_templated "$SCRIPT_DIR/workspace/skills/$skill/SKILL.md" "$WORKSPACE_PATH/skills/$skill/SKILL.md"
done

# Labels, statuses, views
mkdir -p "$WORKSPACE_PATH/labels"
copy_plain "$SCRIPT_DIR/workspace/labels/config.json" "$WORKSPACE_PATH/labels/config.json"

mkdir -p "$WORKSPACE_PATH/statuses"
copy_plain "$SCRIPT_DIR/workspace/statuses/config.json" "$WORKSPACE_PATH/statuses/config.json"

copy_plain "$SCRIPT_DIR/workspace/views.json" "$WORKSPACE_PATH/views.json"

# --- Step 5: Verify ---

echo "[5/5] Verifying..."

ALL_GOOD=true
for check in \
    "$LIFEOS_ROOT/Life OS Framework.md" \
    "$LIFEOS_ROOT/Agent Principles.md" \
    "$LIFEOS_ROOT/AI/Agents/registry.json" \
    "$LIFEOS_ROOT/AI/Agents/Architect/System/README.md" \
    "$WORKSPACE_PATH/skills/start/SKILL.md" \
    "$WORKSPACE_PATH/skills/architect/SKILL.md" \
    "$WORKSPACE_PATH/labels/config.json"; do
    if [ -f "$check" ]; then
        echo "  OK  $check"
    else
        echo "  MISSING  $check"
        ALL_GOOD=false
    fi
done

echo ""
if $ALL_GOOD; then
    echo "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Open Craft Agent"
    echo "  2. Make sure your workspace points to: $WORKSPACE_PATH"
    echo "  3. Add a 'desktop-commander' source (the Architect needs file system access)"
    echo "  4. Start a new session and type /start"
    echo "  5. Select Architect — then create your first agent!"
    echo ""
else
    echo "Setup completed with errors. Check the MISSING files above."
fi
