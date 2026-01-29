# -----------------------------------------------------------------------------
# 40-pre-conditions.mk (40s — Preconditions)
#
# Responsibility: Verify workstation prerequisites (no side effects).
# - required files, tool existence, version checks
#
# Rule: Checks only. Do not start/stop services here.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# ENV (baseline) — local development (non-act)
# -------------------------------------------------------------------

.PHONY: env-help env-init env-init-force check-env

env-help: ## 📖 Environment setup docs
	$(call section,📖  Environment setup)
	@echo "See: docs/onboarding/ENVIRONMENT.md"

env-init: ## 🌱 Create baseline local env files from examples (non-destructive)
	$(call section,🌱  Environment init)
	@set -euo pipefail
	@changed=0

	# .env (project root) — baseline local development
	@if [[ -f ".env" ]]; then \
	  printf "%b\n" "$(GRAY).env already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".env.example" ]]; then \
	    cp ".env.example" ".env"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created .env from .env.example$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .env.example — create .env manually (see docs/onboarding/ENVIRONMENT.md)$(RESET)"; \
	  fi; \
	fi

	@if [[ "$$changed" -eq 0 ]]; then \
	  printf "%b\n" "$(GRAY)No changes made.$(RESET)"; \
	else \
	  printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"; \
	fi

env-init-force: ## 🚨 Force overwrite baseline env files from examples (destructive)
	$(call section,🚨  Environment init (force))
	@set -euo pipefail

	@if [[ -f ".env.example" ]]; then \
	  cp ".env.example" ".env"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote .env from .env.example$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .env.example — cannot overwrite .env$(RESET)"; \
	fi

	@printf "%b\n" "$(GREEN)Done. Re-run: make doctor$(RESET)"

check-env: ## 🌱 Verify required baseline local env file (.env)
	$(call section,🌱  Environment check (baseline))
	$(call require_exec,./scripts/check-required-files.sh)
	@./scripts/check-required-files.sh
