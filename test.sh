#!/usr/bin/env bash
#
# test.sh — smoke tests for install.sh
#
# Usage:
#   ./test.sh              # run all tests
#   bash test.sh
#
# Exits non-zero if any test fails. Works on Linux, macOS, and Windows
# (Git Bash / WSL).

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL="$SCRIPT_DIR/install.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

t() { printf '\n== %s ==\n' "$1"; }

ok() { printf 'PASS: %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf 'FAIL: %s\n' "$1"; fail=$((fail + 1)); }

assert_dir() { # name path
  if [[ -f "$2/SKILL.md" ]]; then ok "$1"; else bad "$1 (missing $2/SKILL.md)"; fi
}

assert_no_dir() { # name path
  if [[ ! -e "$2" ]]; then ok "$1"; else bad "$1 ($2 unexpectedly exists)"; fi
}

assert_grep() { # name pattern file
  if grep -q -- "$2" "$3"; then ok "$1"; else bad "$1 (pattern not found: $2)"; fi
}

skill_names() {
  local d
  for d in "$SCRIPT_DIR"/skills/*/; do
    [[ -f "$d/SKILL.md" ]] && basename "$d"
  done
}
first_skill="$(skill_names | head -n1)"

# --- 1. fresh install produces a flat, spec-compliant layout ---------------
t "fresh install"
target="$TMP/fresh"
bash "$INSTALL" --target "$target" > "$TMP/out1" 2>&1
for s in $(skill_names); do
  assert_dir "install $s" "$target/$s"
done
assert_no_dir "no nested duplicate after fresh install" "$target/$first_skill/$first_skill"

# --- 2. re-run without --force skips existing skills ------------------------
t "re-run without --force skips"
out="$TMP/out2"
bash "$INSTALL" --target "$target" > "$out" 2>&1
assert_grep "skip message shown" "Skip   $first_skill" "$out"
assert_no_dir "still no nested duplicate" "$target/$first_skill/$first_skill"

# --- 3. --force overwrites in place, never nests -----------------------------
t "--force overwrites in place"
bash "$INSTALL" --target "$target" --force > "$TMP/out3" 2>&1
assert_dir "skill still present after --force" "$target/$first_skill"
assert_no_dir "no nested duplicate after --force" "$target/$first_skill/$first_skill"
assert_grep "install message shown" "Install $first_skill" "$TMP/out3"

# --- 4. --force does not leave stale files (real replace, not overlay) -------
t "--force replaces, not overlays"
marker="$target/$first_skill/.stale-marker"
echo stale > "$marker"
bash "$INSTALL" --target "$target" --force > /dev/null 2>&1
assert_no_dir "--force removes files not present in the source" "$marker"

# --- 5. --list ---------------------------------------------------------------
t "--list"
bash "$INSTALL" --list > "$TMP/out5" 2>&1
assert_grep "--list shows first skill" "$first_skill" "$TMP/out5"

# --- 6. --help exits 0 -------------------------------------------------------
t "--help"
if bash "$INSTALL" --help > "$TMP/out6" 2>&1; then
  ok "--help exits 0"
else
  bad "--help exits 0"
fi
assert_grep "--help prints usage" "--target" "$TMP/out6"

# --- 7. unknown option exits non-zero ----------------------------------------
t "unknown option"
if bash "$INSTALL" --definitely-not-an-option > "$TMP/out7" 2>&1; then
  bad "unknown option exits non-zero"
else
  ok "unknown option exits non-zero"
fi
assert_grep "unknown option prints message" "Unknown option" "$TMP/out7"

# --- 8. SKILLS_DIR env var ----------------------------------------------------
t "SKILLS_DIR environment variable"
env_target="$TMP/env-target"
SKILLS_DIR="$env_target" bash "$INSTALL" --force > /dev/null 2>&1
assert_dir "SKILLS_DIR respected" "$env_target/$first_skill"

# --- summary ------------------------------------------------------------------
printf '\n========================================\n'
printf 'Tests: %d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
