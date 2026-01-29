#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check-required-files.sh
#
# Baseline doctor check (required for everyone):
# - Fails fast (errors)
# - Quiet + machine-readable when DOCTOR_JSON=1
# - Human-friendly otherwise
#
# Checks:
#   - .env exists in project root
#
# Notes:
# - This script intentionally excludes act-only requirements (.vars, ~/.actrc, .secrets).
#   Those are checked by: scripts/check-required-files-act.sh
# -----------------------------------------------------------------------------

PROJECT_ENV=".env"
DOCS_ENV="docs/environment/ENV_SPEC.md"

JSON_MODE="${DOCTOR_JSON:-0}"

# ANSI colors (safe even if Make disables color upstream)
RED="\033[1;31m"
GREEN="\033[1;32m"
GRAY="\033[90m"
RESET="\033[0m"

status="pass"
errors=()
warnings=()

emit_json() {
  jq -n \
    --arg status "$status" \
    --argjson errors "$(printf '%s\n' "${errors[@]:-}" | jq -R . | jq -s .)" \
    --argjson warnings "$(printf '%s\n' "${warnings[@]:-}" | jq -R . | jq -s .)" '
    {
      check: "required-files-baseline",
      status: $status,
      errors: $errors,
      warnings: $warnings
    }
  '
}

fail() {
  status="fail"
  errors+=("$1")
}

# -----------------------
# .env (project root)
# -----------------------
if [[ ! -f "$PROJECT_ENV" ]]; then
  fail "Missing $PROJECT_ENV (project root). See: $DOCS_ENV"
elif [[ "$JSON_MODE" != "1" ]]; then
  printf "%b\n" "${GREEN}✅ Found $PROJECT_ENV${RESET}"
fi

# -----------------------
# Output / exit
# -----------------------
if [[ "$JSON_MODE" == "1" ]]; then
  emit_json
  [[ "$status" == "fail" ]] && exit 1 || exit 0
fi

if [[ "$status" == "fail" ]]; then
  echo ""
  printf "%b\n" "${RED}❌ Required environment checks failed:${RESET}"
  for err in "${errors[@]}"; do
    echo "   - $err"
  done
  echo ""
  printf "%b\n" "${GRAY}Fix:${RESET}"
  echo "  👉 Run: make env-init"
  echo "  📖 Docs: $DOCS_ENV"
  exit 1
fi

printf "%b\n" "${GREEN}🎉 Required environment checks passed.${RESET}"
