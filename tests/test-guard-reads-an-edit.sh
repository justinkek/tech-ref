#!/usr/bin/env bash

REPOSITORY="$(cd "$(dirname "$0")/.." && pwd)"
GUARD="$REPOSITORY/hooks/guard-tech-steps.sh"

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

refusal_for() {
  bash "$GUARD" | jq --raw-output '.hookSpecificOutput.permissionDecisionReason // empty'
}

HEADING_120='========================================= add a visualisation of the tech steps ========================================'

TREE_RAGGED="$HEADING_120
  dotfiles/
! ├── CLAUDE.md                                add a section for the drawings that open the tech steps
+ ├── AGENTS.md                                  add the same section one column further out"

through_page="$(jq --null-input --arg content "$TREE_RAGGED" \
  '{tool_input:{command:"insert_content",content:$content}}' |
  refusal_for)"

through_edit="$(jq --null-input --arg written "$TREE_RAGGED" \
  '{tool_name:"Edit",tool_input:{file_path:"/steps.md",old_string:"",new_string:$written}}' |
  refusal_for)"

printf "Test group: an edit reaches the guard the same way a page update does\n"

[ -n "$through_page" ]
assert "the page update is refused" "$?" "the guard let it through"

[ -n "$through_edit" ]
assert "the edit is refused too" "$?" "an edit carries no command, and the guard let it through"

[ "$through_edit" = "$through_page" ]
assert "both refusals name the same line" "$?" \
  "the edit was refused for '$through_edit', the page update for '$through_page'"

printf "\nTest group: an edit carrying no steps is left alone\n"

allowed="$(jq --null-input \
  '{tool_name:"Edit",tool_input:{file_path:"/notes.md",old_string:"",new_string:"Some prose that names no summary, tree or flow."}}' |
  refusal_for)"

[ -z "$allowed" ]
assert "prose passes" "$?" "the guard refused it for '$allowed'"

printf "\n%d passed, %d failed\n" "$pass" "$fail"
[ "$fail" -eq 0 ]
