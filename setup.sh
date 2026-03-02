#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[ok]${NC} $1"; }
skip() { echo -e "${YELLOW}[skip]${NC} $1 (already installed)"; }

# ── Homebrew packages ────────────────────────────────────────
# Add dependencies here: "command:brew-package"
DEPS=(
    "gh:gh"
    "glab:glab"
)

echo ""
echo "==> Installing dependencies..."
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

# ── MCP servers ──────────────────────────────────────────────
# Add MCP servers here. Use prompt() for values that shouldn't be hardcoded.

prompt() {
    local var="$1" desc="$2" value
    read -rp "$desc: " value
    if [ -z "$value" ]; then
        echo "Skipped (no value provided)" >&2
        return 1
    fi
    eval "$var=\$value"
}

echo ""
echo "==> Installing MCP servers..."
echo ""

if prompt CONTEXT7_KEY "Context7 API key"; then
    claude mcp add --scope user --header "CONTEXT7_API_KEY: $CONTEXT7_KEY" --transport http context7 https://mcp.context7.com/mcp \
        && log "context7" || skip "context7"
fi

echo ""
log "Done!"
echo ""
