#!/usr/bin/env bash
# Agent Blueprint - Setup Script (macOS / Linux)
# Usage: ./setup.sh [--root ~/MyAgents] [--workspace ~/.craft-agent/workspaces/my-workspace]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "=== Agent Blueprint Setup ==="
echo ""

# --- Parse args ---

SYSTEM_ROOT=""
WORKSPACE_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --root) SYSTEM_ROOT="$2"; shift 2 ;;
        --workspace) WORKSPACE_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# --- Prompt for user info ---

read -rp "What should the agents call you? " USER_NAME
if [ -z "$USER_NAME" ]; then
    echo "A name is required."
    exit 1
fi

# --- Prompt for paths ---

if [ -z "$SYSTEM_ROOT" ]; then
    DEFAULT="$HOME/Agent Blueprint"
    read -rp "System root folder [$DEFAULT]: " SYSTEM_ROOT
    SYSTEM_ROOT="${SYSTEM_ROOT:-$DEFAULT}"
fi

if [ -z "$WORKSPACE_PATH" ]; then
    DEFAULT="$HOME/.craft-agent/workspaces/my-workspace"
    read -rp "Craft Agent workspace folder [$DEFAULT]: " WORKSPACE_PATH
    WORKSPACE_PATH="${WORKSPACE_PATH:-$DEFAULT}"
fi

# --- Multi-machine setup ---

MACHINE_NAME=""
MACHINE_SLUG=""
MACHINE_CONTEXT="default"

read -rp "Multi-machine setup? (y/N) " MULTI_MACHINE
if [ "$MULTI_MACHINE" = "y" ] || [ "$MULTI_MACHINE" = "Y" ]; then
    read -rp "What is this machine's name? (e.g. Desktop, Work Laptop) " MACHINE_NAME
    if [ -z "$MACHINE_NAME" ]; then
        echo "Machine name is required for multi-machine setup."
        exit 1
    fi
    MACHINE_SLUG=$(echo "$MACHINE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

    read -rp "Context for this machine? (e.g. home, office) [default]: " MACHINE_CONTEXT
    MACHINE_CONTEXT="${MACHINE_CONTEXT:-default}"
fi

# Resolve paths
SYSTEM_ROOT="$(mkdir -p "$SYSTEM_ROOT" && cd "$SYSTEM_ROOT" && pwd)"
mkdir -p "$WORKSPACE_PATH"
WORKSPACE_PATH="$(cd "$WORKSPACE_PATH" && pwd)"

echo ""
echo "User:          $USER_NAME"
echo "System root:   $SYSTEM_ROOT"
echo "Workspace:     $WORKSPACE_PATH"
if [ -n "$MACHINE_NAME" ]; then
    echo "Machine:       $MACHINE_NAME ($MACHINE_SLUG) [$MACHINE_CONTEXT]"
fi
echo ""

read -rp "Proceed? [Y/n] " confirm
if [ -n "$confirm" ] && [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    echo "Aborted."
    exit 1
fi

# --- Helper: copy with template replacement ---

SETUP_DATE=$(date +%Y-%m-%d)

copy_templated() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    sed -e "s|{{SETUP_DATE}}|$SETUP_DATE|g" \
        -e "s|{{USER_NAME}}|$USER_NAME|g" \
        "$src" > "$dest"
}

copy_plain() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
}

# --- Step 1: Create folder structure ---

echo ""
echo "[1/6] Creating folder structure..."

mkdir -p "$SYSTEM_ROOT/AI/Agents/Architect/System"
mkdir -p "$SYSTEM_ROOT/AI/Agents/Architect/Workflows"
mkdir -p "$SYSTEM_ROOT/AI/Agents/Architect/Tools/Templates"
mkdir -p "$SYSTEM_ROOT/AI/Agents/Architect/Tools/Scripts"
mkdir -p "$SYSTEM_ROOT/AI/Agents/Architect/Handover/Archive"
mkdir -p "$SYSTEM_ROOT/AI/Agents/registry"
mkdir -p "$SYSTEM_ROOT/Knowledge"

# --- Step 2: Copy framework docs ---

echo "[2/6] Copying framework docs..."

copy_templated "$SCRIPT_DIR/framework/Life OS Framework.md" "$SYSTEM_ROOT/Life OS Framework.md"
copy_templated "$SCRIPT_DIR/framework/Agent Principles.md" "$SYSTEM_ROOT/Agent Principles.md"

# --- Step 3: Copy Architect agent + registry ---

echo "[3/6] Setting up Architect agent..."

copy_templated "$SCRIPT_DIR/agents/registry/shared.json" "$SYSTEM_ROOT/AI/Agents/registry/shared.json"

# For multi-machine setups, create an empty machine-specific registry
if [ -n "$MACHINE_NAME" ]; then
    echo "[]" > "$SYSTEM_ROOT/AI/Agents/registry/$MACHINE_SLUG.json"
fi
copy_templated "$SCRIPT_DIR/agents/Architect/System/README.md" "$SYSTEM_ROOT/AI/Agents/Architect/System/README.md"
copy_plain "$SCRIPT_DIR/agents/Architect/System/persona.md" "$SYSTEM_ROOT/AI/Agents/Architect/System/persona.md"
copy_plain "$SCRIPT_DIR/agents/Architect/System/responsibilities.md" "$SYSTEM_ROOT/AI/Agents/Architect/System/responsibilities.md"
copy_templated "$SCRIPT_DIR/agents/Architect/Workflows/create-agent.md" "$SYSTEM_ROOT/AI/Agents/Architect/Workflows/create-agent.md"
copy_templated "$SCRIPT_DIR/agents/Architect/Tools/Templates/agent-template.md" "$SYSTEM_ROOT/AI/Agents/Architect/Tools/Templates/agent-template.md"

# Create empty learnings file
echo "# Learnings - Architect" > "$SYSTEM_ROOT/AI/Agents/Architect/System/learnings.md"

# --- Step 4: Write agent-blueprint.json ---

echo "[4/6] Writing agent-blueprint.json..."

if [ -n "$MACHINE_NAME" ]; then
    cat > "$WORKSPACE_PATH/agent-blueprint.json" << BPEOF
{
  "systemRoot": "$SYSTEM_ROOT",
  "user": {
    "name": "$USER_NAME"
  },
  "machine": {
    "name": "$MACHINE_NAME",
    "slug": "$MACHINE_SLUG",
    "context": "$MACHINE_CONTEXT"
  }
}
BPEOF
else
    cat > "$WORKSPACE_PATH/agent-blueprint.json" << BPEOF
{
  "systemRoot": "$SYSTEM_ROOT",
  "user": {
    "name": "$USER_NAME"
  }
}
BPEOF
fi

# --- Step 5: Copy workspace files ---

echo "[5/6] Setting up Craft Agent workspace..."

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

# --- Step 6: Verify ---

echo "[6/6] Verifying..."

ALL_GOOD=true
for check in \
    "$SYSTEM_ROOT/Life OS Framework.md" \
    "$SYSTEM_ROOT/Agent Principles.md" \
    "$SYSTEM_ROOT/AI/Agents/registry/shared.json" \
    "$SYSTEM_ROOT/AI/Agents/Architect/System/README.md" \
    "$SYSTEM_ROOT/AI/Agents/Architect/System/learnings.md" \
    "$WORKSPACE_PATH/agent-blueprint.json" \
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
    echo "  3. Start a new session and type /start"
    echo "  4. Select Architect - then create your first agent!"
    echo ""
else
    echo "Setup completed with errors. Check the MISSING files above."
fi
