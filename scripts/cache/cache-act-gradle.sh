#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/cache/cache-act-gradle.sh
#
# Responsibility: act Gradle cache hygiene (local disk pressure relief).
#
# Commands:
#   info   - show cache path + size (if present)
#   warn   - warn if cache exceeds ACT_GRADLE_CACHE_WARN_GB
#   remove - remove cache (gated by ACT_GRADLE_CACHE_REMOVE=true|auto)
#   clean  - warn + remove (default)
#
# Vars (all optional; defaults match Make defaults):
#   ACT_GRADLE_CACHE_REMOVE=false|true|auto
#   ACT_GRADLE_CACHE_PATH=.gradle-act
#   ACT_GRADLE_CACHE_DRY_RUN=false|true
#   ACT_GRADLE_CACHE_WARN_GB=8
#   ACT_COLIMA_DISK_MIN_FREE_GB=6
#   ACT_COLIMA_PROFILE=default
#   ACT_COLIMA_MIN_FREE_INODES=5000
#
# NOTE:
# - This script prints a best-effort warning when Colima containerd storage
#   (/var/lib/containerd) is low on disk or inodes, because that is a common
#   cause of:
#     "no space left on device" under /var/lib/containerd/.../overlayfs
# -----------------------------------------------------------------------------

cmd="${1:-clean}"

remove_mode="${ACT_GRADLE_CACHE_REMOVE:-auto}"
cache_path="${ACT_GRADLE_CACHE_PATH:-.gradle-act}"
dry_run="${ACT_GRADLE_CACHE_DRY_RUN:-false}"
warn_gb="${ACT_GRADLE_CACHE_WARN_GB:-8}"
min_free_gb="${ACT_COLIMA_DISK_MIN_FREE_GB:-6}"
profile="${ACT_COLIMA_PROFILE:-default}"
min_free_inodes="${ACT_COLIMA_MIN_FREE_INODES:-5000}"

die() {
  echo "❌ $*" >&2
  exit 2
}

is_bool() {
  case "${1}" in true|false) return 0 ;; *) return 1 ;; esac
}

is_int() {
  [[ "${1}" =~ ^[0-9]+$ ]]
}

validate() {
  case "${remove_mode}" in true|false|auto) ;; *) die "Invalid ACT_GRADLE_CACHE_REMOVE=${remove_mode} (use true|false|auto)" ;; esac
  is_bool "${dry_run}" || die "Invalid ACT_GRADLE_CACHE_DRY_RUN=${dry_run} (use true|false)"
  is_int "${warn_gb}" || die "Invalid ACT_GRADLE_CACHE_WARN_GB=${warn_gb} (use integer GB)"
  is_int "${min_free_gb}" || die "Invalid ACT_COLIMA_DISK_MIN_FREE_GB=${min_free_gb} (use integer GB)"
  is_int "${min_free_inodes}" || die "Invalid ACT_COLIMA_MIN_FREE_INODES=${min_free_inodes} (use integer)"
}

cache_exists() {
  [[ -d "${cache_path}" ]]
}

cache_kb() {
  du -sk "${cache_path}" 2>/dev/null | awk '{print $1}' || echo 0
}

print_info() {
  if cache_exists; then
    echo "📦 Cache path: ${cache_path}"
    du -sh "${cache_path}" 2>/dev/null || true
  else
    echo "ℹ️ No act Gradle cache found (${cache_path})"
  fi
}

warn_if_large() {
  cache_exists || return 0

  local kb warn_kb
  kb="$(cache_kb)"
  warn_kb="$(( warn_gb * 1024 * 1024 ))"

  if [[ "${kb}" -gt "${warn_kb}" ]]; then
    echo "⚠️  act Gradle cache is larger than ${warn_gb}GB (consider cleaning)"
  fi
}

colima_running() {
  command -v colima >/dev/null 2>&1 || return 1
  colima status --profile "${profile}" >/dev/null 2>&1
}

colima_containerd_free_gb() {
  colima ssh --profile "${profile}" -- sh -lc \
    'df -BG /var/lib/containerd 2>/dev/null | awk "NR==2 {gsub(/G/,\"\", \$4); print \$4}"' \
    2>/dev/null || true
}

colima_containerd_free_inodes() {
  colima ssh --profile "${profile}" -- sh -lc \
    'df -Pi /var/lib/containerd 2>/dev/null | awk "NR==2 {print \$4}"' \
    2>/dev/null || true
}

warn_containerd_pressure() {
  # IMPORTANT: this must be defined before main() calls it.
  # Best-effort; never fails the run.
  if ! colima_running; then
    return 0
  fi

  local free_gb free_inodes warned="false"
  free_gb="$(colima_containerd_free_gb)"
  free_inodes="$(colima_containerd_free_inodes)"

  if [[ -n "${free_gb}" && "${free_gb}" =~ ^[0-9]+$ ]]; then
    if [[ "${free_gb}" -lt "${min_free_gb}" ]]; then
      echo "⚠️  Colima containerd free disk is low: ${free_gb}GB (< ${min_free_gb}GB)"
      warned="true"
    fi
  fi

  if [[ -n "${free_inodes}" && "${free_inodes}" =~ ^[0-9]+$ ]]; then
    if [[ "${free_inodes}" -lt "${min_free_inodes}" ]]; then
      echo "⚠️  Colima containerd free inodes is low: ${free_inodes} (< ${min_free_inodes})"
      warned="true"
    fi
  fi

  if [[ "${warned}" == "true" ]]; then
    echo "💡 Tip: this often causes 'no space left on device' under /var/lib/containerd/overlayfs."
    echo "   Try: make clean-docker CLEAN_DOCKER_MODE=true CLEAN_DOCKER_VERBOSE=true"
    echo "   Docs: make help-local-hygiene"
  fi
}

should_remove_auto() {
  if ! colima_running; then
    echo "ℹ️ Auto mode: colima profile '${profile}' not running or colima not installed; skipping cache removal"
    return 1
  fi

  local free_gb free_inodes
  free_gb="$(colima_containerd_free_gb)"
  free_inodes="$(colima_containerd_free_inodes)"

  if [[ -n "${free_gb}" && "${free_gb}" =~ ^[0-9]+$ ]]; then
    echo "🖥️  Colima containerd free disk: ${free_gb}GB (threshold: < ${min_free_gb}GB)"
    if [[ "${free_gb}" -lt "${min_free_gb}" ]]; then
      echo "🧹 Auto mode triggered (low containerd disk)"
      return 0
    fi
  fi

  if [[ -n "${free_inodes}" && "${free_inodes}" =~ ^[0-9]+$ ]]; then
    echo "🧾 Colima containerd free inodes: ${free_inodes} (threshold: < ${min_free_inodes})"
    if [[ "${free_inodes}" -lt "${min_free_inodes}" ]]; then
      echo "🧹 Auto mode triggered (low containerd inodes)"
      return 0
    fi
  fi

  echo "ℹ️ Auto mode: containerd storage OK; not removing cache"
  return 1
}

remove_cache() {
  # Gate: only run when enabled
  if [[ "${remove_mode}" != "true" && "${remove_mode}" != "auto" ]]; then
    return 0
  fi

  if ! cache_exists; then
    echo "ℹ️ No act Gradle cache found (${cache_path})"
    return 0
  fi

  if [[ "${remove_mode}" == "auto" ]]; then
    should_remove_auto || return 0
  fi

  # Show size before removal
  print_info

  if [[ "${dry_run}" == "true" ]]; then
    echo "🟡 Dry run — would remove ${cache_path}"
  else
    echo "❌ Removing ${cache_path}"
    rm -rf "${cache_path}"
  fi
}

usage() {
  cat <<'EOF'
Usage:
  scripts/cache/cache-act-gradle.sh [command]

Commands:
  info    Show cache path + size
  warn    Warn if cache exceeds ACT_GRADLE_CACHE_WARN_GB
  remove  Remove cache if ACT_GRADLE_CACHE_REMOVE=true|auto
  clean   warn + remove (default)

Environment variables:
  ACT_GRADLE_CACHE_REMOVE=false|true|auto
  ACT_GRADLE_CACHE_PATH=.gradle-act
  ACT_GRADLE_CACHE_DRY_RUN=false|true
  ACT_GRADLE_CACHE_WARN_GB=8
  ACT_COLIMA_DISK_MIN_FREE_GB=6
  ACT_COLIMA_PROFILE=default
  ACT_COLIMA_MIN_FREE_INODES=5000
EOF
}

main() {
  validate

  case "${cmd}" in
    info)   print_info ;;
    warn)   warn_containerd_pressure; warn_if_large ;;
    remove) warn_containerd_pressure; remove_cache ;;
    clean)  warn_containerd_pressure; warn_if_large; remove_cache ;;
    -h|--help|help) usage ;;
    *) die "Unknown command: ${cmd} (use info|warn|remove|clean)" ;;
  esac
}

main "$@"
