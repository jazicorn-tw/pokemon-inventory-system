#!/usr/bin/env bash
set -euo pipefail

# Inspect every mk module in a decade with consolidated target summary first.
# Usage: scripts/inspect/inspect-decade-all.sh 50

DECADE="${1:-}"
if [[ -z "${DECADE}" ]]; then
  echo "Usage: inspect-decade-all.sh <decade>" >&2
  exit 2
fi

BOLD="${BOLD:-$'\033[1m'}"
RESET="${RESET:-$'\033[0m'}"
CYAN="${CYAN:-$'\033[36m'}"
GRAY="${GRAY:-$'\033[90m'}"

printf "%s🧭 Decade %s%s%s — consolidated targets%s\n\n" "${BOLD}" "${CYAN}" "${DECADE}" "${RESET}" "${RESET}"

# Build list of files in decade using exact ordering contract.
mapfile -t FILES < <(ls -1 make | sort | awk -v d="${DECADE}" '$0 ~ ("^" d "-.*\\.mk$") { print "make/" $0 }')

if [[ "${#FILES[@]}" -eq 0 ]]; then
  echo "❌ No make modules found for decade ${DECADE}" >&2
  exit 1
fi

# Consolidated unique targets (documented with ##)
# shellcheck disable=SC2016
(
  for f in "${FILES[@]}"; do
    grep -hE '^[a-zA-Z0-9_-]+:.*## ' "${f}" || true
  done
) | awk -F':' '{print $1}' | sort -u | sed 's/^/  • /'

printf "\n%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n\n" "${GRAY}" "${RESET}"

# Then inspect each file in order
for f in "${FILES[@]}"; do
  scripts/inspect/inspect-file.sh "${f}"
  echo
done
