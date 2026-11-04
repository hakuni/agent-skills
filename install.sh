#!/usr/bin/env bash
#
# install.sh — install/update skills from this repo into an Agent Skills
# directory (e.g. ~/.agents/skills/).
#
# Usage:
#   ./install.sh [options]
#
# Options:
#   -t, --target <dir>   Skills directory to install into
#                        (default: $SKILLS_DIR or ~/.agents/skills)
#   -f, --force          Overwrite skills that already exist
#   -l, --list           List available skills and exit
#   -h, --help           Show this help message
#
# Works on Linux, macOS, and Windows (Git Bash / WSL).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
TARGET="${SKILLS_DIR:-$HOME/.agents/skills}"
FORCE=0

usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

log() { printf '%s\n' "$*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) TARGET="$2"; shift 2 ;;
    -f|--force)  FORCE=1; shift ;;
    -l|--list)   LIST_ONLY=1; shift ;;
    -h|--help)   usage ;;
    *) log "Unknown option: $1" >&2; usage 1 ;;
  esac
done

if [[ ! -d "$SKILLS_SRC" ]]; then
  log "Error: skills directory not found at $SKILLS_SRC"
  log "Run this script from the repository root."
  exit 1
fi

# Collect skills (directories containing SKILL.md)
available=()
for dir in "$SKILLS_SRC"/*/; do
  [[ -f "$dir/SKILL.md" ]] && available+=("$(basename "$dir")")
done

if [[ "${LIST_ONLY:-0}" == "1" ]]; then
  log "Available skills:"
  for s in "${available[@]:-}"; do log "  - $s"; done
  exit 0
fi

if [[ ${#available[@]} -eq 0 ]]; then
  log "No skills found in $SKILLS_SRC"
  exit 1
fi

mkdir -p "$TARGET"
installed=0
skipped=0

for name in "${available[@]}"; do
  src="$SKILLS_SRC/$name"
  dest="$TARGET/$name"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    log "Skip   $name (already exists at $dest, use --force to overwrite)"
    skipped=$((skipped + 1))
    continue
  fi

  # Replace the target in place: cp would nest or overlay if dest exists,
  # so remove it first (also drops stale files deleted from the source).
  rm -rf "$dest"
  cp -R "$src" "$dest"
  log "Install $name -> $dest"
  installed=$((installed + 1))
done

log ""
log "Done. Installed: $installed, Skipped: $skipped, Target: $TARGET"
log "Restart your agent session (or run /reload) to pick up new skills."
