#!/bin/bash
# azure_helper.sh - Shared utilities for monitoring scripts

# ─────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────

LOG_FILE="${LOG_FILE:-/var/log/azure-monitor/remediation.log}"

log_info()  { _log "INFO"  "$*"; }
log_warn()  { _log "WARN"  "$*"; }
log_error() { _log "ERROR" "$*"; }

_log() {
  local level=$1; shift
  local message="$*"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  echo "[$level] $timestamp $message"
  echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}" \
    >> "$LOG_FILE"
}

# ─────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────

# Retry with exponential backoff
retry() {
  local n=0
  until [ $n -ge 5 ]; do
    "$@" && return 0
    n=$((n + 1))
    log_warn "Retry $n/5 failed: $*"
    sleep $((2 ** n))
  done
  log_error "All retries failed: $*"
  return 1
}

# Lock file, prevents concurrent remediation executions
acquire_lock() {
  local lock_file="/tmp/remediation_$1.lock"
  if [ -f "$lock_file" ]; then
    log_warn "Remediation already in progress for $1"
    return 1
  fi
  touch "$lock_file"
  trap "rm -f $lock_file" EXIT
  return 0
}