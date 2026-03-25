#!/bin/bash
# remediation.sh - Execute remediation actions directly on vm1


source /opt/scripts/azure_helper.sh

CPU_THRESHOLD=80
MEM_THRESHOLD_GB=1
DISK_THRESHOLD=90

# ─────────────────────────────────────────
# REMEDIATIONS
# ─────────────────────────────────────────

remediate_cpu() {
  log_info "Initiating CPU remediation"

  acquire_lock "cpu" || return 1

  # Kill zombie processes
  local zombies
  zombies=$(ps aux | awk '$8=="Z"' | wc -l)
  if [ "$zombies" -gt 0 ]; then
    log_warn "$zombies zombie processes found — cleaning"
    ps aux | awk '$8=="Z" {print $2}' | xargs -r kill -9
  fi

  # Log top 5 processes by CPU
  log_info "Top 5 processes by CPU:"
  ps aux --sort=-%cpu | head -6 | tee -a "$LOG_FILE"

  # Restart critical services if down
  for service in nginx apache2 app; do
    systemctl is-active "$service" &>/dev/null || {
      log_warn "Service $service is down — restarting"
      sudo systemctl restart "$service"
    }
  done

  log_info "CPU remediation completed"
}

remediate_memory() {
  log_info "Initiating memory remediation"

  acquire_lock "memory" || return 1

  local mem_before
  mem_before=$(free -g | awk '/^Mem:/{print $7}')
  log_info "Available memory before: ${mem_before}GB"

  if [ "$mem_before" -lt "$MEM_THRESHOLD_GB" ]; then
    sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

    local mem_after
    mem_after=$(free -g | awk '/^Mem:/{print $7}')
    log_info "Available memory after: ${mem_after}GB"
  else
    log_info "Memory OK — no action required"
  fi
}

remediate_disk() {
  log_info "Initiating disk remediation"

  acquire_lock "disk" || return 1

  local disk_before
  disk_before=$(df / | awk 'NR==2 {print $5}')
  log_info "Disk usage before: $disk_before"

  local disk_pct
  disk_pct=$(echo "$disk_before" | tr -d '%')

  if [ "$disk_pct" -gt "$DISK_THRESHOLD" ]; then
    log_warn "Critical disk usage — cleaning"

    sudo find /var/log -name "*.log" -mtime +7 -delete
    sudo find /var/log -name "*.gz" -mtime +3 -delete
    sudo journalctl --vacuum-time=3d
    sudo apt-get clean -y

    local disk_after
    disk_after=$(df / | awk 'NR==2 {print $5}')
    log_info "Disk usage after: $disk_after"
  else
    log_info "Disk OK — no action required"
  fi
}

# ─────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────

case "$1" in
  cpu)    remediate_cpu ;;
  memory) remediate_memory ;;
  disk)   remediate_disk ;;
  *)
    log_warn "No type specified — running all remediations"
    remediate_cpu
    remediate_memory
    remediate_disk
    ;;
esac