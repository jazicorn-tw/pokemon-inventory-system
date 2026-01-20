#!/usr/bin/env bash
set -euo pipefail

# Check that tracked repo scripts have the executable bit set in Git.
#
# Default behavior:
#   - WARN only (local dev)
#
# CI behavior:
#   - Set STRICT=1 to FAIL the build on any missing executable bit
#
# Why this exists:
#   - Git hooks (.githooks/*) MUST be executable to run
#   - Shell scripts under scripts/ MUST be executable to avoid "permission denied"
#
# This script only inspects *tracked files* to avoid noise from local-only scripts.

STRICT="${STRICT:-0}"

# Patterns of tracked files that are expected to be executable
PATTERNS=(
  "scripts/*.sh"
  ".githooks/*"
)

# Ensure we run from repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "check-executable-bits: not in a git repo; skipping."
  exit 0
fi
cd "${REPO_ROOT}"

missing=()

for pat in "${PATTERNS[@]}"; do
  # Iterate only over tracked files matching the pattern
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    [[ -f "${file}" ]] || continue

    # Git file mode (first column): 100755 = executable, 100644 = not executable
    mode="$(git ls-files --stage -- "${file}" | awk '{print $1}')"

    if [[ "${mode}" != "100755" ]]; then
      missing+=("${file}")
    fi
  done < <(git ls-files -- "${pat}" || true)
done

if (( ${#missing[@]} == 0 )); then
  echo "check-executable-bits: OK (all tracked scripts are executable)."
  exit 0
fi

echo "check-executable-bits: Found tracked files missing executable bit:"
for f in "${missing[@]}"; do
  echo "  - ${f}"
done

cat <<'EOF'

Fix locally:
  chmod +x <file(s)>
  git add <file(s)>
  git commit -m "chore(dev): make scripts and hooks executable"

Why this matters:
  - Git ignores non-executable hooks (e.g. .githooks/commit-msg)
  - CI and local tooling may fail with 'permission denied'

Tip:
  If this keeps happening, ensure bootstrap scripts apply +x
  immediately after cloning.

EOF

if [[ "${STRICT}" == "1" ]]; then
  echo "check-executable-bits: STRICT=1 -> failing."
  exit 1
fi

echo "check-executable-bits: WARNING only (STRICT=0)."
exit 0
