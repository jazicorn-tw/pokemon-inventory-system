#!/usr/bin/env bash
set -euo pipefail

# Check that tracked repo scripts have the executable bit set in Git.
# Default behavior: WARN only.
# In CI, set STRICT=1 to FAIL the build on any missing executable bit.

STRICT="${STRICT:-0}"

# Patterns of files we expect to be executable *when tracked in git*.
# Adjust if you add more script dirs.
PATTERNS=(
  "scripts/*.sh"
  ".githooks/*"
)

# Ensure we run from repo root.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "check-executable-bits: not in a git repo; skipping."
  exit 0
fi
cd "${REPO_ROOT}"

missing=()

for pat in "${PATTERNS[@]}"; do
  # Only consider tracked files (prevents noise from local-only scripts).
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue

    # Mode is the first field: 100755 (exec) vs 100644 (non-exec)
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

echo "check-executable-bits: Found tracked scripts without executable bit:"
for f in "${missing[@]}"; do
  echo "  - ${f}"
done

cat <<'EOF'

Fix locally:
  chmod +x <file(s)>
  git add <file(s)>
  git commit -m "chore(dev): make scripts executable"

Tip:
  If this keeps happening, ensure your bootstrap installs +x on scripts.

EOF

if [[ "${STRICT}" == "1" ]]; then
  echo "check-executable-bits: STRICT=1 -> failing."
  exit 1
fi

echo "check-executable-bits: WARNING only (STRICT=0)."
exit 0
