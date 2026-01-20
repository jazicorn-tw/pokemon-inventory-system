# Developer convenience aliases
# These do NOT replace CI; they mirror ADR-000 locally.

SHELL := /usr/bin/env bash

.PHONY: help hooks doctor clean clean-all exec-bits format lint quality test verify test-ci bootstrap

help:
	@echo ""
	@echo "🧰 Make targets"
	@echo "  make doctor     - Environment sanity (local only)"
	@echo "  make lint       - Static analysis only (fast-ish)"
	@echo "  make test       - Unit tests"
	@echo "  make verify     - Doctor + lint + test (good before pushing)"
	@echo "  make quality    - Doctor + format + clean check (matches CI intent)"
	@echo "  make bootstrap  - Install hooks + run full local quality gate"
	@echo "  make hooks      - Install repo-local git hooks"
	@echo "  make exec-bits  - Check tracked scripts executable bit (warn locally)"
	@echo "  make clean      - Clean build outputs only (Gradle clean)"
	@echo "  make clean-all  - Full local reset (removes .gradle state + clean)"
	@echo ""


hooks:
	@bash ./scripts/install-hooks.sh

# Clean build outputs only.
# Fast, safe, and equivalent to Gradle's standard clean.
clean:
	@./gradlew --no-daemon clean

# Full local reset.
# Removes all Gradle state (including configuration cache and Spotless JVM cache)
# to recover from corrupted or stale local builds.
clean-all:
	@rm -rf .gradle
	@./gradlew --no-daemon clean
	
# Check executable bits (WARN locally). In CI, set STRICT=1 to fail.
exec-bits:
	@if [[ -f ./scripts/check-executable-bits.sh ]]; then \
		bash ./scripts/check-executable-bits.sh; \
	else \
		echo "exec-bits: scripts/check-executable-bits.sh not found; skipping."; \
	fi

# Local environment sanity (human-facing)
doctor: clean-all exec-bits
	@bash ./scripts/precheck.sh
	@echo "Doctor complete: environment looks ready."

# Auto-format (mutates files)
format: 
	@rm -rf .gradle/configuration-cache
	@./gradlew --no-daemon --no-configuration-cache -q spotlessApply
	
# Static analysis only (fast-ish)
lint:
	@./gradlew --no-daemon -q checkstyleMain pmdMain spotbugsMain

# Full local quality gate (matches CI intent)
quality: doctor
	@./gradlew --no-daemon -q clean check

# Unit tests (no implicit doctor to avoid double-running; use make test or make verify)
test: doctor
	@./gradlew --no-daemon -q test

# Umbrella target: what a developer should run before pushing / opening a PR
verify: doctor lint test
	@echo "Verify complete: environment + code checks passed."

# CI parity run (forces CI semantics; no auto-format)
test-ci: doctor
	@CI=true SPRING_PROFILES_ACTIVE=test ./gradlew --no-daemon --stacktrace clean check

# Install hooks + run the full quality gate (recommended after clone)
bootstrap: hooks quality
	@echo "Bootstrap complete: hooks installed and quality gate passed."
