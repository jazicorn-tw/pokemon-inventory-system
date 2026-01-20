#!/usr/bin/env bash
set -euo pipefail

# Install repo-local git hooks.
# This keeps hooks versioned and consistent across machines.

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

git config core.hooksPath .githooks

chmod +x .githooks/pre-commit || true

echo "Installed git hooks:"
echo "  core.hooksPath = .githooks"
echo ""
echo "Tip: bypass once with:"
echo "  SKIP_QUALITY=1 git commit -m "...""
