#!/bin/bash
# CodePilot - One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Trustydev212/CodePilot/main/setup.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  echo ""
  echo -e "${BLUE}\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557${NC}"
  echo -e "${BLUE}\u2551          CodePilot Installer          \u2551${NC}"
  echo -e "${BLUE}\u2551   Fullstack Developer Toolkit for     \u2551${NC}"
  echo -e "${BLUE}\u2551           Claude Code                 \u2551${NC}"
  echo -e "${BLUE}\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d${NC}"
  echo ""
}

print_step() {
  echo -e "${GREEN}[\u2713]${NC} $1"
}

print_warn() {
  echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
  echo -e "${RED}[\u2717]${NC} $1"
}

print_header

if ! command -v git &>/dev/null; then
  print_error "git is not installed. Please install git first."
  exit 1
fi

if ! command -v jq &>/dev/null; then
  print_warn "jq is not installed. Hooks will not work without it."
  print_warn "Install: brew install jq (macOS) or apt install jq (Linux)"
fi

INSTALL_DIR="${1:-.}"

if [ "$INSTALL_DIR" = "--global" ] || [ "$INSTALL_DIR" = "-g" ]; then
  INSTALL_DIR="$HOME"
  CLAUDE_DIR="$HOME/.claude"
  GLOBAL=true
  echo -e "Installing ${BLUE}globally${NC} to ~/.claude"
else
  CLAUDE_DIR="$INSTALL_DIR/.claude"
  GLOBAL=false
  echo -e "Installing to ${BLUE}$INSTALL_DIR${NC}"
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo "Downloading CodePilot..."
git clone --quiet --depth 1 https://github.com/Trustydev212/CodePilot.git "$TEMP_DIR" 2>/dev/null || {
  print_error "Failed to download CodePilot. Check your internet connection."
  exit 1
}
print_step "Downloaded"

if [ -d "$CLAUDE_DIR" ]; then
  print_warn "Existing .claude directory found"
  echo "  Merging without overwriting your existing files..."
  MERGE=true
else
  MERGE=false
fi

if [ "$MERGE" = true ]; then
  cp -rn "$TEMP_DIR/.claude/skills" "$CLAUDE_DIR/" 2>/dev/null || true
  cp -rn "$TEMP_DIR/.claude/hooks" "$CLAUDE_DIR/" 2>/dev/null || true
  cp -rn "$TEMP_DIR/.claude/rules" "$CLAUDE_DIR/" 2>/dev/null || true
  cp -rn "$TEMP_DIR/.claude/agents" "$CLAUDE_DIR/" 2>/dev/null || true

  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$TEMP_DIR/.claude/settings.json" "$CLAUDE_DIR/"
  else
    print_warn "Keeping your existing settings.json"
  fi
else
  cp -r "$TEMP_DIR/.claude" "$INSTALL_DIR/"
fi

if [ ! -f "$INSTALL_DIR/CLAUDE.md" ]; then
  cp "$TEMP_DIR/CLAUDE.md" "$INSTALL_DIR/"
  print_step "Created CLAUDE.md"
else
  print_warn "Keeping your existing CLAUDE.md"
fi

if [ ! -f "$INSTALL_DIR/.mcp.json" ] && [ ! -f "$INSTALL_DIR/.mcp.json.example" ]; then
  cp "$TEMP_DIR/.mcp.json.example" "$INSTALL_DIR/.mcp.json.example"
  print_step "Created .mcp.json.example"
fi

chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
print_step "Made hooks executable"

echo ""
echo -e "${BLUE}Detected stack:${NC}"

[ -f "$INSTALL_DIR/package.json" ] && print_step "Node.js"
[ -f "$INSTALL_DIR/tsconfig.json" ] && print_step "TypeScript"
([ -f "$INSTALL_DIR/next.config.js" ] || [ -f "$INSTALL_DIR/next.config.ts" ] || [ -f "$INSTALL_DIR/next.config.mjs" ]) && print_step "Next.js"
([ -f "$INSTALL_DIR/nuxt.config.ts" ] || [ -f "$INSTALL_DIR/nuxt.config.js" ]) && print_step "Nuxt/Vue"
[ -f "$INSTALL_DIR/svelte.config.js" ] && print_step "SvelteKit"
([ -f "$INSTALL_DIR/requirements.txt" ] || [ -f "$INSTALL_DIR/pyproject.toml" ]) && print_step "Python"
[ -f "$INSTALL_DIR/go.mod" ] && print_step "Go"
[ -f "$INSTALL_DIR/Cargo.toml" ] && print_step "Rust"
[ -f "$INSTALL_DIR/prisma/schema.prisma" ] && print_step "Prisma ORM"
([ -f "$INSTALL_DIR/drizzle.config.ts" ] || [ -f "$INSTALL_DIR/drizzle.config.js" ]) && print_step "Drizzle ORM"
([ -f "$INSTALL_DIR/docker-compose.yml" ] || [ -f "$INSTALL_DIR/docker-compose.yaml" ]) && print_step "Docker"

echo ""
echo -e "${GREEN}\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557${NC}"
echo -e "${GREEN}\u2551       CodePilot installed!            \u2551${NC}"
echo -e "${GREEN}\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d${NC}"
echo ""

SKILLS=$(find "$CLAUDE_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
AGENTS=$(find "$CLAUDE_DIR/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
HOOKS=$(find "$CLAUDE_DIR/hooks" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
RULES=$(find "$CLAUDE_DIR/rules" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "  Skills: $SKILLS | Agents: $AGENTS | Hooks: $HOOKS | Rules: $RULES"
echo ""
echo "  Quick start commands:"
echo "    /feature <description>  - Build a feature end-to-end"
echo "    /fix <issue>            - Fix a bug with root cause analysis"
echo "    /review                 - 6-aspect code review"
echo "    /ship                   - Pre-flight checks before deploy"
echo "    /mode token-efficient   - Save 40-70% on tokens"
echo ""
echo "  Run /index to map your codebase first!"
echo ""
