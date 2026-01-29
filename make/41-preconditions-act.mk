# -----------------------------------------------------------------------------
# 41-preconditions-act.mk (40s — Preconditions)
#
# Responsibility: Verify *act-specific* workstation prerequisites (no side effects).
#
# Why a separate file?
# - `act` is an optional local CI simulation tool.
# - Contributors should not be forced to configure act just to run the app/tests.
# - This isolates act-only contracts (like `.vars`, `~/.actrc`, `.secrets`) from baseline onboarding.
#
# Rule: Checks only. Do not start/stop services here.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# ENV / ACT — local CI simulation helpers
# -------------------------------------------------------------------

.PHONY: env-help-act env-init-act env-init-act-force check-env-act

env-help-act: ## 📖 act environment setup docs
	$(call section,📖  act environment setup)
	@echo "See: docs/environment/ENV_SPEC_ACT.md"

env-init-act: ## 🧪 Create act-only local env files from examples (non-destructive)
	$(call section,🧪  Environment init (act))
	@set -euo pipefail
	@changed=0

	# .vars (project root) — act-only contract
	@if [[ -f ".vars" ]]; then \
	  printf "%b\n" "$(GRAY).vars already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".vars.example" ]]; then \
	    cp ".vars.example" ".vars"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created .vars from .vars.example$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .vars.example — create .vars manually (see docs/onboarding/ENVIRONMENT.md)$(RESET)"; \
	  fi; \
	fi

	# .secrets (project root) — act/release simulation auth
	@if [[ -f ".secrets" ]]; then \
	  printf "%b\n" "$(GRAY).secrets already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".secrets.example" ]]; then \
	    cp ".secrets.example" ".secrets"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created .secrets from .secrets.example$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .secrets.example — create .secrets manually (see SECRETS.md)$(RESET)"; \
	  fi; \
	fi

	# ~/.actrc (home directory) — act configuration
	@if [[ -f "$$HOME/.actrc" ]]; then \
	  printf "%b\n" "$(GRAY)$$HOME/.actrc already exists (skipping)$(RESET)"; \
	else \
	  if [[ -f ".actrc.example" ]]; then \
	    cp ".actrc.example" "$$HOME/.actrc"; \
	    chmod 600 "$$HOME/.actrc"; \
	    printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Created $$HOME/.actrc from .actrc.example (chmod 600)$(RESET)"; \
	    changed=1; \
	  else \
	    printf "%b\n" "$(YELLOW)Missing .actrc.example — create $$HOME/.actrc manually (see docs/onboarding/ENVIRONMENT.md)$(RESET)"; \
	  fi; \
	fi

	@if [[ "$$changed" -eq 0 ]]; then \
	  printf "%b\n" "$(GRAY)No changes made.$(RESET)"; \
	else \
	  printf "%b\n" "$(GREEN)Done. Next: make bootstrap-act$(RESET)"; \
	fi

env-init-act-force: ## 🚨 Force overwrite act-only env files from examples (destructive)
	$(call section,🚨  Environment init (act, force))
	@set -euo pipefail

	@if [[ -f ".vars.example" ]]; then \
	  cp ".vars.example" ".vars"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote .vars from .vars.example$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .vars.example — cannot overwrite .vars$(RESET)"; \
	fi

	@if [[ -f ".secrets.example" ]]; then \
	  cp ".secrets.example" ".secrets"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote .secrets from .secrets.example$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .secrets.example — cannot overwrite .secrets$(RESET)"; \
	fi

	@if [[ -f ".actrc.example" ]]; then \
	  cp ".actrc.example" "$$HOME/.actrc"; \
	  chmod 600 "$$HOME/.actrc"; \
	  printf "%b\n" "$(CYAN)▶$(RESET) $(BOLD)Overwrote $$HOME/.actrc from .actrc.example (chmod 600)$(RESET)"; \
	else \
	  printf "%b\n" "$(YELLOW)Missing .actrc.example — cannot overwrite $$HOME/.actrc$(RESET)"; \
	fi

	@printf "%b\n" "$(GREEN)Done.$(RESET)"

check-env-act: ## 🧪 Verify act-only local env files (.vars + .secrets + ~/.actrc)
	$(call section,🧪  Environment check (act))
	$(call require_exec,./scripts/check-required-files-act.sh)
	@./scripts/check-required-files-act.sh
