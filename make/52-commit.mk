\
# -----------------------------------------------------------------------------
# make/52-commit.mk
#
# Optional convenience wrappers for committing.
#
# Usage:
#   make commit MSG="fix: message"
#   make commit-strict MSG="feat: risky message"
#
# Notes:
# - These targets run `git commit -m "$(MSG)"`.
# - They exist to make STRICT_RELEASE_CONFIRM easy to toggle.
# - You can delete this file if you prefer `cz commit` exclusively.
# -----------------------------------------------------------------------------

.PHONY: commit commit-strict

commit: ## 📝 Commit with -m (MSG="type: message")
	@if [ -z "$(MSG)" ]; then \
	  echo "❌ MSG is required. Example: make commit MSG='fix: update docs'"; \
	  exit 1; \
	fi
	@git commit -m "$(MSG)"

commit-strict: ## 🔒 Commit with STRICT_RELEASE_CONFIRM=1 (MSG="type: message")
	@if [ -z "$(MSG)" ]; then \
	  echo "❌ MSG is required. Example: make commit-strict MSG='feat: risky change'"; \
	  exit 1; \
	fi
	@STRICT_RELEASE_CONFIRM=1 git commit -m "$(MSG)"
