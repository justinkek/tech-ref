#!/usr/bin/env bash

REPOSITORY="$(cd "$(dirname "$0")/.." && pwd)"

pass=0
fail=0

HARNESSES='claude|codex|zcode|pi'

report() {
  local label="$1" hits="$2"
  if [ -z "$hits" ]; then
    printf "  OK  %s\n" "$label"
    pass=$((pass + 1))
  else
    printf "  KO  %s\n" "$label"
    printf '%s\n' "$hits" | sed 's/^/        /'
    fail=$((fail + 1))
  fi
}

printf "Test group: what every harness shares names none of them\n"

report "the rules name none of: $HARNESSES" \
  "$(grep --line-number --ignore-case --extended-regexp "\b($HARNESSES)\b" "$REPOSITORY/rules/tech-steps.md")"

printf "\n%d passed, %d failed\n" "$pass" "$fail"
[ "$fail" -eq 0 ]
