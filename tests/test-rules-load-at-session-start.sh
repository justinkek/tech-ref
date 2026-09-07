#!/usr/bin/env bash

REPOSITORY="$(cd "$(dirname "$0")/.." && pwd)"
LOADER="$REPOSITORY/hooks/load-agents-md.sh"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

pass=0
fail=0

assert() {
  local label="$1" outcome="$2" detail="$3"
  if [ "$outcome" = "0" ]; then
    printf "  OK  %s\n" "$label"
    pass=$((pass + 1))
  else
    printf "  KO  %s — %s\n" "$label" "$detail"
    fail=$((fail + 1))
  fi
}

payload="$(jq --null-input --compact-output \
  '{hook_event_name:"SessionStart",session_id:"test-load",source:"startup"}')"
printed="$(printf '%s' "$payload" | bash "$LOADER" 2>/dev/null)"

printf "Test group: the pointer reaches the session\n"

printf '%s' "$printed" | grep --quiet --fixed-strings "## Implementation steps"
assert "the loader prints ## Implementation steps" "$?" "no such heading on stdout"

printf '%s' "$printed" | grep --quiet --fixed-strings "$REPOSITORY/rules/tech-steps.md"
assert "the pointer carries an absolute path" "$?" \
  "it printed '$(printf '%s' "$printed" | grep 'tech-steps.md')', and an installed copy is unpacked elsewhere"

printf '%s' "$printed" | grep --quiet --extended-regexp '(^| )rules/tech-steps\.md'
[ "$?" = "1" ]
assert "and no relative one is left beside it" "$?" "a relative path reached the session too"

printf "\nTest group: no rules pointer, no output\n"

mkdir -p "$TMPDIR/hooks"
cp "$LOADER" "$TMPDIR/hooks/load-agents-md.sh"
absent="$(printf '%s' "$payload" | bash "$TMPDIR/hooks/load-agents-md.sh" 2>/dev/null)"
status="$?"

[ "$status" = "0" ]
assert "it exits 0 with no AGENTS.md beside it" "$?" "exited $status"

[ -z "$absent" ]
assert "it prints nothing with no AGENTS.md beside it" "$?" "printed '$absent'"

printf "\n%d passed, %d failed\n" "$pass" "$fail"
[ "$fail" -eq 0 ]
