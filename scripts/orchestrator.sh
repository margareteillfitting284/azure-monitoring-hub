#!/bin/bash

source /opt/scripts/azure_helper.sh

CPU_THRESHOLD=80
MEM_THRESHOLD=90
DISK_THRESHOLD=90

get_cpu() {
  grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}'
}

get_memory() {
  free | awk '/^Mem:/{printf "%.0f", $3/$2*100}'
}

get_disk() {
  df / | awk 'NR==2 {print int($5)}'
}

# ----------------------
# ORCHESTRATION
# ----------------------

CPU=$(get_cpu)
MEMORY=$(get_memory)
DISK=$(get_disk)

log_info "Current state -> CPU: ${CPU}% | Memory: ${MEMORY}% | Disk: ${DISK}%"
TRIGGERED=false

if [ "$CPU" -gt "$CPU_THRESHOLD" ]; then
  log_warn "CPU usage is above threshold (${CPU}%)"
  bash /opt/scripts/remediation.sh cpu
  TRIGGERED=true
fi

if [ "$MEMORY" -gt "$MEM_THRESHOLD" ]; then
  log_warn "Memory usage is above threshold (${MEMORY}%)"
  bash /opt/scripts/remediation.sh memory
  TRIGGERED=true
fi

if [ "$DISK" -gt "$DISK_THRESHOLD" ]; then
  log_warn "Disk usage is above threshold (${DISK}%)"
  bash /opt/scripts/remediation.sh disk
  TRIGGERED=true
fi

if [ "$TRIGGERED" = false ]; then
  log_info "All metrics are within thresholds. No remediation needed."
fi