#!/usr/bin/env bash
set -euo pipefail

# scripts/inspect/inspect-list.sh
#
# Lists make/ modules in sorted order, grouped by decade headers.
# Output: headers + one-column entries: <emoji> <filename>
#
# Read-only. No args required.
#
# Ordering contract: ls -1 make | sort

BOLD="${BOLD:-$'\033[1m'}"
RESET="${RESET:-$'\033[0m'}"
CYAN="${CYAN:-$'\033[36m'}"
YELLOW="${YELLOW:-$'\033[33m'}"
GRAY="${GRAY:-$'\033[90m'}"

echo "${BOLD}📂 Available make/ modules${RESET}"
echo

# Extract the decade bucket from filename (e.g. 31-foo.mk → 30)
get_decade_bucket() {
  local name="$1"
  printf '%s\n' "$name" | sed -nE 's/^([0-9])[0-9].*/\10/p'
}

# Emoji for a decade bucket (00, 10, 20, ...)
emoji_for_decade() {
  local decade="$1"
  case "${decade}" in
    00) printf "⚙️  " ;; # Kernel
    10) printf "🎛️  " ;; # Presentation
    20) printf "🔧 "  ;; # Configuration
    30) printf "🧭 "  ;; # Interface
    40) printf "🧰 "  ;; # Preconditions
    50) printf "🧩 "  ;; # Library / utilities
    60) printf "✅ "  ;; # Verification
    70) printf "🚀 "  ;; # Runtime
    80) printf "🧪 "  ;; # Simulation
    90) printf "📦 "  ;; # Delivery
    *)  printf "🔹 "  ;; # Fallback
  esac
}

# Human header label for a decade bucket
label_for_decade() {
  local decade="$1"
  case "${decade}" in
    00) printf "00s — Kernel" ;;
    10) printf "10s — Presentation" ;;
    20) printf "20s — Configuration" ;;
    30) printf "30s — Interface" ;;
    40) printf "40s — Preconditions" ;;
    50) printf "50s — Library" ;;
    60) printf "60s — Verification" ;;
    70) printf "70s — Runtime" ;;
    80) printf "80s — Simulation" ;;
    90) printf "90s — Delivery" ;;
    *)  printf "Other" ;;
  esac
}

current_decade=""

while IFS= read -r f; do
  decade="$(get_decade_bucket "${f}")"

  # New decade group => print a header
  if [[ "${decade}" != "${current_decade}" ]]; then
    # Separate groups with a blank line (except before the first)
    if [[ -n "${current_decade}" ]]; then
      echo
    fi

    header="$(label_for_decade "${decade}")"
    printf "%s%s%s\n" "${GRAY}" "${header}" "${RESET}"
    current_decade="${decade}"
  fi

  tag="$(emoji_for_decade "${decade}")"

  # One-column entry: emoji + filename
  printf "  %s%s%s %s%s%s\n" "${YELLOW}" "${tag}" "${RESET}" "${CYAN}" "${f}" "${RESET}"
done < <(ls -1 make | sort)
