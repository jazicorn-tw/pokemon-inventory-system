#!/usr/bin/env bash
set -euo pipefail

# Install repo-local git hooks.
# This keeps hooks versioned and consistent across machines.

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

git config core.hooksPath .githooks

# Ensure hooks are executable (prevents "Permission denied" on commit).
chmod +x .githooks/* 2>/dev/null || true

# Ensure repo scripts are executable (prevents "Permission denied" in make targets).
chmod +x scripts/*.sh 2>/dev/null || true

echo "Installed git hooks:"
echo "  core.hooksPath = .githooks"
echo ""
echo "Tip: bypass once with:"
echo "  SKIP_QUALITY=1 git commit -m \"...\""
