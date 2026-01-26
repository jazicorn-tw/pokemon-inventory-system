# -----------------------------------------------------------------------------
# mk/65-runtime.mk
#
# Local dev environment helpers.
#
# Notes:
# - `make start` is idempotent: safe to run repeatedly.
# - It only starts prerequisites (Colima + optional Compose), not Gradle/app.
# -----------------------------------------------------------------------------

.PHONY: start stop status

start: ## 🚀 Start local dev prerequisites (Colima + optional Compose)
	@./scripts/start-dev.sh

stop: ## 🛑 Stop local dev stack (Compose) and Colima
	@./scripts/stop-dev.sh

status: ## 🔎 Show docker + colima status
	@echo "docker context: $$(docker context show 2>/dev/null || echo 'n/a')"
	@colima status 2>/dev/null || true
	@docker ps 2>/dev/null | head -n 15 || true
