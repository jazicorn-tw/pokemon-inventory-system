# -----------------------------------------------------------------------------
# 90-helm.mk (90s — Delivery)
#
# Responsibility: Packaging and delivery tooling (helm, release packaging).
#
# Rule: High consequence. Require explicit intent and strong guards.
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Helm / Deploy (prep-only)
# -------------------------------------------------------------------

.PHONY: helm deploy

helm: ## 🧰 Helm is prep-only (ADR-009)
	$(call step,🧰 Helm (prep-only))
	@printf "%b\n" "$(CYAN)Helm$(RESET) is prep-only $(GRAY)(ADR-009)$(RESET)."
	@echo "See: docs/onboarding/HELM.md"

deploy: ## 🚧 Deploy is not wired yet
	$(call step,🚧 Deploy (not wired))
	@printf "%b\n" "$(YELLOW)Deploy$(RESET) is not wired yet."
	@echo "See: docs/onboarding/DEPLOY.md"
