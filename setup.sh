#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_SRC="$SCRIPT_DIR/plugins"
PLUGINS_DST="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"

ONLY=""
while (( $# )); do
  case "$1" in
    --plugins-dir) PLUGINS_DST="$2"; shift 2;;
    --only)        ONLY="$2"; shift 2;;
    -h|--help)
      echo "Usage: $0 [--plugins-dir <path>] [--only p1,p2,p3]"
      exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 64;;
  esac
done

mkdir -p "$PLUGINS_DST"

if [[ -n "$ONLY" ]]; then
  IFS=',' read -r -a SELECTED <<< "$ONLY"
else
  SELECTED=()
  for d in "$PLUGINS_SRC"/*/; do
    SELECTED+=("$(basename "$d")")
  done
fi

count=0
for name in "${SELECTED[@]}"; do
  src="$PLUGINS_SRC/$name"
  dst="$PLUGINS_DST/libre-secops-$name"
  [[ ! -d "$src" ]] && { echo "  [skip] $name (not found)"; continue; }
  [[ -d "$dst" ]] && { echo "  [skip] libre-secops-$name (already installed)"; continue; }
  cp -r "$src" "$dst"
  echo "  [ok]   libre-secops-$name"
  count=$((count + 1))
done

echo ""
echo "Installed $count plugins."
echo "Restart Claude Code, then try: /threat-model build a STRIDE model for a SaaS feature"
