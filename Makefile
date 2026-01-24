# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

.DEFAULT_GOAL := help

# --- Developer settings ---
LOCAL_SETTINGS ?= .config/local-settings.json

# Workflows to run when invoking `make act-all`
ACT_WORKFLOWS ?= ci-fast ci-quality ci-test image-build image-publish

# --- act (local GitHub Actions) ---
ACT ?= act
ACT_IMAGE ?= catthehacker/ubuntu:full-latest
ACT_PLATFORM ?= linux/amd64
ACT_DOCKER_SOCK ?= /var/run/docker.sock

# -----------------------------------------------------------------------------
# act runner tuning (Gradle cache + safer networking defaults)
# -----------------------------------------------------------------------------
ACT_GRADLE_CACHE_DIR ?=
ACT_GRADLE_CACHE_DIR_EFFECTIVE := $(or $(strip $(ACT_GRADLE_CACHE_DIR)),$(CURDIR)/.gradle-act)

# Use JAVA_TOOL_OPTIONS to avoid quoting issues inside `--container-options`
ACT_JAVA_TOOL_OPTIONS := -Djava.net.preferIPv4Stack=true -Dorg.gradle.internal.http.connectionTimeout=60000 -Dorg.gradle.internal.http.socketTimeout=60000

# Use docker-short flags and single-quotes for values containing spaces
ACT_CONTAINER_OPTS ?= \
  -e JAVA_TOOL_OPTIONS='$(ACT_JAVA_TOOL_OPTIONS)' \
  -e GRADLE_USER_HOME=/tmp/gradle \
  -v $(ACT_GRADLE_CACHE_DIR_EFFECTIVE):/tmp/gradle

# Capture positional args after the target name (for run-ci/list-ci/explain)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
WORKFLOW_ARG := $(word 1,$(ARGS))
JOB := $(word 2,$(ARGS))
WORKFLOW := $(if $(WORKFLOW_ARG),$(WORKFLOW_ARG),ci-test)
WORKFLOW_FILE := .github/workflows/$(WORKFLOW).yml

# Detect current git branch (Phase 0: direct commits to main)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

.PHONY: \
  help \
  help-ci \
  explain \
  debug \
  local-settings \
  exec-bits \
  hooks \
  doctor \
  clean \
  clean-all \
  format \
  lint \
  test \
  verify \
  quality \
  test-ci \
  bootstrap \
  pre-commit \
  docker-volume \
  docker-up \
  docker-down \
  docker-reset \
  db-shell \
  act \
  act-all \
  run-ci \
  list-ci \
  helm \
  deploy

# -------------------------------------------------------------------
# HELP / DOCS
# -------------------------------------------------------------------

help: ## 🧰 Show developer help (grouped)
	@echo ""
	@echo "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo "\033[1;36m🧰  Pokémon Trainer Platform — Make Targets\033[0m"
	@echo "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	@echo ""
	@echo "\033[1;33m🚀 Recommended flow\033[0m"
	@echo "  \033[1mmake bootstrap\033[0m   → first-time setup"
	@echo "  \033[1mmake verify\033[0m      → before pushing"
	@echo "  \033[1mmake run-ci\033[0m      → simulate CI locally (act)"
	@echo ""
	@echo "\033[1;33m🧪 Quality gates\033[0m"
	@echo "  make doctor        - Local environment sanity checks"
	@echo "  make lint          - Static analysis only (fast-ish)"
	@echo "  make test          - Unit tests"
	@echo "  make verify        - Doctor + lint + test (good before pushing)"
	@echo "  make quality       - Doctor + spotlessCheck + clean check (matches CI intent)"
	@echo "  make pre-commit    - Smart gate (strict on main, fast elsewhere)"
	@echo ""
	@echo "\033[1;33m🐳 Docker / DB\033[0m"
	@echo "  make docker-up     - Start local Docker Compose services"
	@echo "  make docker-down   - Stop local Docker Compose services"
	@echo "  make docker-reset  - Stop services + delete volumes + restart"
	@echo "  make db-shell      - psql shell into local postgres container"
	@echo ""
	@echo "\033[1;33m🧪 act (local GitHub Actions)\033[0m"
	@echo "  make run-ci [wf] [job] - Run workflow/job via act (defaults to wf=ci-test)"
	@echo "  make list-ci [wf]      - List jobs for workflow via act"
	@echo "  make act               - Alias of: make run-ci"
	@echo "  make act-all           - Run all local CI workflows via act"
	@echo ""
	@echo "\033[1;33m📦 Helm / Deploy (prep-only)\033[0m"
	@echo "  make helm          - Helm is prep-only (ADR-009) → docs/onboarding/HELM.md"
	@echo "  make deploy        - Deploy is not wired yet → docs/onboarding/DEPLOY.md"
	@echo ""

help-ci: ## 🧰 Show only CI-relevant targets
	@echo ""
	@echo "CI: verify, quality, test-ci, run-ci, list-ci"
	@echo ""

explain: ## 🧠 Explain a target: make explain <target>
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
	  echo "❌ Usage: make explain <target>"; exit 1; \
	fi
	@t="$(word 2,$(MAKECMDGOALS))"; \
	case "$$t" in \
	  doctor)  echo "doctor: runs local sanity checks (java/gradle/docker/colima/socket)";; \
	  verify)  echo "verify: doctor + lint + test (recommended before pushing)";; \
	  quality) echo "quality: doctor + spotlessCheck + clean + check (matches CI intent)";; \
	  pre-commit) echo "pre-commit: smart gate (main → quality, others → fast gate)";; \
	  run-ci)  echo "run-ci: run GitHub Actions workflows locally via act (wf defaults to ci-test; optional job)";; \
	  *) echo "No extended explanation available for '$$t' (see docs/MAKEFILE.md)";; \
	esac

debug: ## 🧾 Print effective tool configuration
	@echo "ACT=$(ACT)"
	@echo "ACT_IMAGE=$(ACT_IMAGE)"
	@echo "ACT_PLATFORM=$(ACT_PLATFORM)"
	@echo "ACT_DOCKER_SOCK=$(ACT_DOCKER_SOCK)"
	@echo "ACT_GRADLE_CACHE_DIR_EFFECTIVE=$(ACT_GRADLE_CACHE_DIR_EFFECTIVE)"
	@echo "WORKFLOW=$(WORKFLOW)"
	@echo "JOB=$(JOB)"
	@echo "WORKFLOW_FILE=$(WORKFLOW_FILE)"
	@echo "GIT_BRANCH=$(GIT_BRANCH)"

# -------------------------------------------------------------------
# CONFIG / UTIL
# -------------------------------------------------------------------

local-settings: ## 🧩 Print effective local settings
	@echo "LOCAL_SETTINGS=$(LOCAL_SETTINGS)"
	@test -f "$(LOCAL_SETTINGS)" && cat "$(LOCAL_SETTINGS)" || echo "No local settings file found."

exec-bits: ## 🔧 Check & (optionally) auto-fix executable bits for tracked scripts
	@CHECK_EXECUTABLE_BITS_CONFIG="$(LOCAL_SETTINGS)" ./scripts/check-executable-bits.sh

hooks: ## 🪝 Configure repo-local git hooks
	@./scripts/install-hooks.sh

doctor: ## 🩺 Local environment sanity checks
	@./scripts/doctor.sh

clean: ## 🧹 Clean build outputs
	@./gradlew --no-daemon -q clean

clean-all: ## 🧹 Clean build + purge local caches (use sparingly)
	@./gradlew --no-daemon -q clean
	@rm -rf .gradle build

# -------------------------------------------------------------------
# PRE-COMMIT POLICY (Phase 0 aware)
# -------------------------------------------------------------------

pre-commit: ## 🪝 Smart pre-commit gate (strict on main)
	@if [ "$(GIT_BRANCH)" = "main" ]; then \
	  echo "🪝 pre-commit: on 'main' → running quality"; \
	  $(MAKE) quality; \
	else \
	  echo "🪝 pre-commit: on '$(GIT_BRANCH)' → running fast gate (format + lint + test)"; \
	  $(MAKE) format lint test; \
	fi

format: ## ✨ Auto-format sources
	@if [ "$${NUKE_GRADLE_CACHE:-0}" = "1" ]; then \
	  echo "⚠️  NUKE_GRADLE_CACHE=1 → removing Gradle caches"; \
	  rm -rf .gradle/configuration-cache .gradle/caches; \
	fi
	@./gradlew --no-daemon -q --no-configuration-cache spotlessApply

lint: ## 🔎 Static analysis only (fast-ish)
	@./gradlew --no-daemon -q --no-configuration-cache checkstyleMain checkstyleTest pmdMain pmdTest spotbugsMain spotbugsTest

test: ## 🧪 Unit tests
	@./gradlew --no-daemon -q test

verify: doctor lint test ## ✅ Doctor + lint + test
	@echo "✅ verify complete"

quality: doctor ## ✅ Doctor + spotlessCheck + clean check (matches CI intent)
	@./gradlew --no-daemon -q spotlessCheck clean check

test-ci: ## CI: Run CI-equivalent test suite locally
	@./gradlew --no-daemon -q clean test

bootstrap: hooks exec-bits quality ## 🚀 Install hooks + run full local quality gate
	@echo "✅ bootstrap complete"

# -------------------------------------------------------------------
# DOCKER / DB
# -------------------------------------------------------------------

docker-volume: ## 🐳 List local Docker volumes (postgres-focused)
	@docker volume ls | grep -i postgres || true

docker-up: ## 🐳 Start local Docker Compose services
	@docker compose up -d

docker-down: ## 🐳 Stop local Docker Compose services
	@docker compose down

docker-reset: ## 🧨 Reset local Docker environment (containers + volumes)
	@echo "⚠️  Resetting local Docker environment (containers + volumes)"
	@docker compose down -v
	@docker compose up -d

db-shell: ## 🐘 Open a psql shell in the postgres container
	@docker compose exec postgres psql -U $${POSTGRES_USER:-trainer} -d $${POSTGRES_DB:-trainer}

# -------------------------------------------------------------------
# act — Local GitHub Actions simulation
# -------------------------------------------------------------------

act: run-ci ## 🧪 Alias: run one workflow via act

act-all: ## 🧪 Run all local CI workflows via act
	@for wf in $(ACT_WORKFLOWS); do \
	  echo ""; \
	  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
	  echo "🧪 act → workflow=$$wf"; \
	  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
	  $(MAKE) run-ci $$wf || exit $$?; \
	done

run-ci: ## 🧪 Run workflow/job via act (auto-detect event)
	@if [ ! -f "$(WORKFLOW_FILE)" ]; then \
	  echo "❌ Workflow not found: $(WORKFLOW_FILE)"; \
	  echo "👉 Try: ls .github/workflows"; \
	  exit 1; \
	fi

	@mkdir -p "$(ACT_GRADLE_CACHE_DIR_EFFECTIVE)"
	@echo "🧪 act → workflow=$(WORKFLOW) job=$(JOB)"

	@events="push pull_request workflow_dispatch"; \
	if [ -n "$(JOB)" ]; then events="workflow_dispatch push pull_request"; fi; \
	for ev in $$events; do \
	  echo "🔎 trying event=$$ev"; \
	  tmp="$$(mktemp)"; \
	  set +e; \
	  ACT=true $(ACT) $$ev \
	    -W $(WORKFLOW_FILE) \
	    $(if $(JOB),-j $(JOB),) \
	    -P ubuntu-latest=$(ACT_IMAGE) \
	    --container-daemon-socket $(ACT_DOCKER_SOCK) \
	    --container-architecture $(ACT_PLATFORM) \
	    --container-options="--user 0:0 $(ACT_CONTAINER_OPTS)" \
	    2>&1 | tee "$$tmp"; \
	  status="$$?"; \
	  set -e; \
	  if ! grep -q "Could not find any stages to run" "$$tmp"; then \
	    rm -f "$$tmp"; \
	    exit "$$status"; \
	  fi; \
	  rm -f "$$tmp"; \
	done; \
	echo "❌ No runnable jobs found for workflow=$(WORKFLOW)"; \
	exit 1

list-ci: ## 📋 List jobs for a workflow via act
	@$(ACT) -W $(WORKFLOW_FILE) --list

# Swallow extra args ONLY for targets that accept positionals
.PHONY: $(ARGS)
$(ARGS):
	@:

# -------------------------------------------------------------------
# Helm / Deploy (prep-only)
# -------------------------------------------------------------------

helm: ## 🧰 Helm is prep-only (ADR-009)
	@echo "🧰 Helm is prep-only (ADR-009)."
	@echo "See: docs/onboarding/HELM.md"

deploy: ## 🚧 Deploy is not wired yet
	@echo "🚧 Deploy is not wired yet."
	@echo "See: docs/onboarding/DEPLOY.md"
