#!/usr/bin/env bash
# Claude Code status line — robbyrussell theme style
set -euo pipefail

# Single jq call extracts all fields (tab-separated)
IFS=$'\t' read -r cwd model used used_tokens total_tokens branch < <(
  jq -r '[
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.context_window.used_percentage // ""),
    (.context_window.used // ""),
    (.context_window.total // ""),
    (.worktree.branch // "")
  ] | join("\t")'
)

dir_base="${cwd##*/}"
: "${dir_base:=$(basename "$(pwd)")}"

# Fallback only when JSON didn't provide branch
if [ -z "$branch" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

green='\033[1;32m'
cyan='\033[0;36m'
blue='\033[1;34m'
red='\033[0;31m'
yellow='\033[0;33m'
reset='\033[0m'

arrow="${green}➜${reset}"
dir_part="${cyan}${dir_base}${reset}"

git_part=""
if [ -n "$branch" ]; then
  if GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-.}" diff --quiet HEAD 2>/dev/null; then
    git_part=" ${blue}git:(${red}${branch}${blue})${reset}"
  else
    git_part=" ${blue}git:(${red}${branch}${blue}) ${yellow}✗${reset}"
  fi
fi

fmt_tokens() {
  local n="${1%%.*}"
  n="${n:-0}"
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    local m=$((n / 1000000)) r=$(( (n % 1000000) / 100000 ))
    if [ "$r" -gt 0 ]; then printf '%s.%sM' "$m" "$r"; else printf '%sM' "$m"; fi
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    printf '%sK' "$((n / 1000))"
  else
    printf '%s' "$n"
  fi
}

ctx_part=""
if [ -n "$used" ]; then
  used_int="${used%%.*}"
  if [ -n "$used_tokens" ] && [ -n "$total_tokens" ]; then
    ctx_part="  ctx: $(fmt_tokens "$used_tokens")/$(fmt_tokens "$total_tokens") ${used_int}%"
  else
    ctx_part="  ctx: ${used_int}%"
  fi
fi

model_part=""
if [ -n "$model" ]; then
  model_part="  ${model}"
fi

printf '%b' "${arrow} ${dir_part}${git_part}${ctx_part}${model_part}"
