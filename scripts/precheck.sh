#!/usr/bin/env bash
set -euo pipefail

# Local environment pre-flight checks.
# - Fast fail for missing Docker/Colima/Java/Gradle wrapper
# - Does NOT auto-start anything (explicit is better than implicit)
# - Safe to run on macOS (Colima or Docker Desktop) + Linux (Docker Engine)
#
# Optional knobs:
#   PRECHECK_REQUIRE_COLIMA=1        -> fail if Colima isn't installed (macOS-only preference)
#   PRECHECK_MIN_DOCKER_MEM_GB=4     -> warn if Docker reports less (best-effort)
#   PRECHECK_STRICT=1               -> treat warnings as failures
#
# CI behavior:
#   If CI=true/1, this script exits immediately (local convenience only).

# Internal environment checks invoked by `make doctor`.
# This script is not meant to be called directly by contributors.

say() { printf "%s\n" "$*"; }
ok()  { say "✅ $*"; }
warn(){ say "⚠️  $*"; }
die() { say "❌ $*"; exit 1; }

# CI guard (local-only helper)
if [[ "${CI:-}" == "true" || "${CI:-}" == "1" ]]; then
  say "CI detected; skipping local pre-checks."
  exit 0
fi

STRICT="${PRECHECK_STRICT:-0}"
MIN_MEM_GB="${PRECHECK_MIN_DOCKER_MEM_GB:-4}"
REQUIRE_COLIMA="${PRECHECK_REQUIRE_COLIMA:-0}"

if [[ "${STRICT}" == "1" ]]; then
  WARN_AS_FAIL=1
else
  WARN_AS_FAIL=0
fi

warn_or_die() {
  if [[ "${WARN_AS_FAIL}" == "1" ]]; then
    die "$1"
  else
    warn "$1"
  fi
}

say "🔎 Running local pre-checks..."

# --- Java (project expects Java 21) ---
if ! command -v java >/dev/null 2>&1; then
  die "Java not found. Install Java 21 (Temurin recommended) and ensure 'java' is on PATH."
fi

JAVA_VERSION_RAW="$(java -version 2>&1 | head -n 1 || true)"
JAVA_MAJOR="$(echo "${JAVA_VERSION_RAW}" | sed -E 's/.*version "([0-9]+).*/\1/' || true)"
if [[ -z "${JAVA_MAJOR}" || "${JAVA_MAJOR}" == "${JAVA_VERSION_RAW}" ]]; then
  warn "Could not parse Java version from: ${JAVA_VERSION_RAW}"
else
  if [[ "${JAVA_MAJOR}" -lt 21 ]]; then
    die "Java ${JAVA_MAJOR} detected; this project expects Java 21+. (${JAVA_VERSION_RAW})"
  fi
  ok "java OK (${JAVA_VERSION_RAW})"
fi

# --- Gradle wrapper ---
if [[ ! -f "./gradlew" ]]; then
  die "Gradle wrapper not found (./gradlew). Run from the repo root, or ensure the wrapper is committed."
fi
if [[ ! -x "./gradlew" ]]; then
  warn_or_die "Gradle wrapper exists but is not executable. Fix with: chmod +x ./gradlew"
else
  ok "gradle wrapper OK (./gradlew)"
fi

# --- docker CLI ---
if ! command -v docker >/dev/null 2>&1; then
  die "Docker CLI not found. Install Docker Desktop (macOS/Windows) or Docker Engine (Linux), or Colima (macOS)."
fi
ok "docker CLI found"

OS="$(uname -s || true)"

HAS_COLIMA=0
if command -v colima >/dev/null 2>&1; then
  HAS_COLIMA=1
  ok "colima found"
  if ! colima status >/dev/null 2>&1; then
    die "Colima is installed but not running. Start it with: colima start"
  fi
  ok "colima is running"
else
  if [[ "${OS}" == "Darwin" && "${REQUIRE_COLIMA}" == "1" ]]; then
    die "Colima not found but PRECHECK_REQUIRE_COLIMA=1. Install it (brew install colima) or unset PRECHECK_REQUIRE_COLIMA."
  fi
  if [[ "${OS}" == "Darwin" ]]; then
    warn "colima not found. If you're using Docker Desktop, this is fine."
  else
    ok "colima not required on ${OS}"
  fi
fi

if ! docker info >/dev/null 2>&1; then
  if [[ "${OS}" == "Darwin" && "${HAS_COLIMA}" == "1" ]]; then
    die "Docker daemon not reachable. Colima may be misconfigured. Try: colima restart"
  fi
  die "Docker daemon not reachable. Start Docker Desktop (macOS/Windows) or start the Docker service (Linux)."
fi
ok "docker daemon reachable"

PROVIDER="unknown"
INFO="$(docker info 2>/dev/null || true)"
if echo "${INFO}" | grep -qi "docker desktop"; then
  PROVIDER="docker-desktop"
elif echo "${INFO}" | grep -qi "colima"; then
  PROVIDER="colima"
elif echo "${INFO}" | grep -qi "rancher desktop"; then
  PROVIDER="rancher-desktop"
elif echo "${INFO}" | grep -qi "podman"; then
  PROVIDER="podman"
fi
ok "docker provider: ${PROVIDER}"

MEM_GB=""
MEM_LINE="$(echo "${INFO}" | sed -n 's/^ *Total Memory: *//p' | head -n 1 || true)"
if [[ -n "${MEM_LINE}" ]]; then
  MEM_NUM="$(echo "${MEM_LINE}" | sed -E 's/[^0-9.].*$//' || true)"
  if [[ -n "${MEM_NUM}" ]]; then
    MEM_GB="${MEM_NUM}"
  fi
fi

if [[ -n "${MEM_GB}" ]]; then
  awk -v mem="${MEM_GB}" -v min="${MIN_MEM_GB}" 'BEGIN { exit (mem+0 < min+0) }'     || warn_or_die "Docker reports ~${MEM_GB} GiB memory; recommended >= ${MIN_MEM_GB} GiB for Gradle + Testcontainers."
  ok "memory check: ~${MEM_GB} GiB"
else
  warn "Could not determine Docker memory from 'docker info' (provider=${PROVIDER}). Skipping memory check."
fi

if ! docker images >/dev/null 2>&1; then
  die "Docker socket seems unhealthy (cannot list images). Restart your Docker provider."
fi
ok "docker socket healthy"

ok "Pre-checks passed."
