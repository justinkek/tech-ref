#!/usr/bin/env bash

cat >/dev/null

root="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$root/AGENTS.md" ] || exit 0

sed "s|rules/|$root/rules/|g" "$root/AGENTS.md"
