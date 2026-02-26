#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[ok]${NC} $1"; }
skip() { echo -e "${YELLOW}[skip]${NC} $1 (already installed)"; }

# Add dependencies here: "command:brew-package"
DEPS=(
    "gh:gh"
    "glab:glab"
)

echo ""
echo "Installing Claude Code dependencies..."
echo ""

for entry in "${DEPS[@]}"; do
    cmd="${entry%%:*}"
    pkg="${entry##*:}"

    if command -v "$cmd" &>/dev/null; then
        skip "$pkg"
    else
        brew install "$pkg"
        log "$pkg"
    fi
done

echo ""
log "Done!"
echo ""
