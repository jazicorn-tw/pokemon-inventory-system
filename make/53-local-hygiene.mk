# -----------------------------------------------------------------------------
# 53-local-hygiene.mk
#
# Responsibility: local cache & disk hygiene orchestration.
#
# This file exposes a small, discoverable Make interface and delegates
# all heavy logic to scripts under scripts/cache/.
#
# Scripts:
# - scripts/cache/cache-act-gradle.sh
# - scripts/cache/cache-docker.sh
# - scripts/cache/clean-colima.sh
# - scripts/cache/clean-local.sh
#
# Design:
# - Safe by default (all destructive actions gated by vars)
# - Make = orchestration, scripts = logic
# -----------------------------------------------------------------------------

# -------------------------------------------------------------------
# Script paths (overrideable)
# -------------------------------------------------------------------
PATH_ACT ?= ./scripts/cache/cache-act-gradle.sh
PATH_DOCKER ?= ./scripts/cache/cache-docker.sh
PATH_COLIMA ?= ./scripts/cache/clean-colima.sh
PATH_LOCAL ?= ./scripts/cache/clean-local.sh

# -------------------------------------------------------------------
# Configuration (defaults)
# -------------------------------------------------------------------
# Override per-run:
#   make clean-local CLEAN_DOCKER_MODE=auto CLEAN_DOCKER_AUTO_MIN_FREE_GB=8
# -------------------------------------------------------------------

# --- act / Gradle cache --------------------------------------------
ACT_GRADLE_CACHE_REMOVE ?= auto
ACT_GRADLE_CACHE_PATH ?= .gradle-act
ACT_GRADLE_CACHE_DRY_RUN ?= false
ACT_GRADLE_CACHE_WARN_GB ?= 8
ACT_COLIMA_DISK_MIN_FREE_GB ?= 6
ACT_COLIMA_PROFILE ?= default
ACT_COLIMA_MIN_FREE_INODES ?= 5000

# --- docker cache ---------------------------------------------------
# CLEAN_DOCKER_MODE: false|true|auto (explicit opt-in)
CLEAN_DOCKER_MODE ?= auto
CLEAN_DOCKER_VOLUMES ?= false
CLEAN_DOCKER_VERBOSE ?= false
CLEAN_DOCKER_AUTO_MIN_FREE_GB ?= 10
CLEAN_DOCKER_AUTO_MIN_FREE_INODES ?= 5000
CLEAN_DOCKER_COLIMA_PROFILE ?= default

# --- colima ---------------------------------------------------------
# Colima reset is *nuclear* and is intentionally NOT part of clean-local.
# Run `make clean-colima` explicitly when needed.
CLEAN_COLIMA_RESET ?= false
CLEAN_COLIMA_DISK_GB ?= 80
CLEAN_COLIMA_PROFILE ?= default
CLEAN_COLIMA_ASSUME_YES ?= false


# -------------------------------------------------------------------
# Export knobs to recipe environments
# -------------------------------------------------------------------

export ACT_GRADLE_CACHE_REMOVE
export ACT_GRADLE_CACHE_PATH
export ACT_GRADLE_CACHE_DRY_RUN
export ACT_GRADLE_CACHE_WARN_GB
export ACT_COLIMA_DISK_MIN_FREE_GB
export ACT_COLIMA_PROFILE
export ACT_COLIMA_MIN_FREE_INODES

export CLEAN_DOCKER_MODE
export CLEAN_DOCKER_VOLUMES
export CLEAN_DOCKER_VERBOSE
export CLEAN_DOCKER_AUTO_MIN_FREE_GB
export CLEAN_DOCKER_AUTO_MIN_FREE_INODES
export CLEAN_DOCKER_COLIMA_PROFILE

export CLEAN_COLIMA_RESET
export CLEAN_COLIMA_DISK_GB
export CLEAN_COLIMA_PROFILE
export CLEAN_COLIMA_ASSUME_YES


# -------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------

.PHONY: \
	act-gradle-cache-info act-gradle-cache-warn act-gradle-cache-remove clean-act \
	docker-cache-info clean-docker \
	colima-info clean-colima \
	clean-local-info clean-local


# --- act / Gradle cache --------------------------------------------

act-gradle-cache-info: ## ℹ️  Show act Gradle cache path + size
	@"$(PATH_ACT)" info

act-gradle-cache-warn: ## ⚠️  Warn if act Gradle cache exceeds threshold
	@"$(PATH_ACT)" warn

act-gradle-cache-remove: ## 🧹 Remove act Gradle cache (gated)
	@"$(PATH_ACT)" remove

clean-act: ## 🧹 act hygiene (warn + optional remove)
	@"$(PATH_ACT)" clean


# --- docker cache ---------------------------------------------------

docker-cache-info: ## ℹ️  Show docker context + disk usage
	@"$(PATH_DOCKER)" info

clean-docker: ## 🧹 Docker cache prune (gated)
	@"$(PATH_DOCKER)" prune


# --- colima ---------------------------------------------------------

colima-info: ## ℹ️  Show colima status
	@"$(PATH_COLIMA)" info

clean-colima: ## ♻️ Reset colima VM (NUCLEAR; gated + prompt)
	@"$(PATH_COLIMA)" reset


# --- umbrella -------------------------------------------------------

clean-local-info: ## ℹ️  Show local hygiene snapshot (act + docker + colima status)
	@"$(PATH_LOCAL)" info

clean-local: ## 🧼 Run local hygiene (act + docker). Colima reset is explicit via clean-colima.
	@"$(PATH_LOCAL)" clean
