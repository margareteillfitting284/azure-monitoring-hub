#!/bin/bash
# manual_setup.sh - Prepares the monitoring environment inside vm1 and vm2
# Run this script once inside vm1 via Bastion
# Usage: bash manual_setup.sh

set -e

echo "[INFO] Creating directories..."
sudo mkdir -p /opt/scripts
sudo mkdir -p /var/log/azure-monitor

echo "[INFO] Setting permissions..."
sudo chown -R "$USER:$USER" /var/log/azure-monitor

echo "[INFO] Copying scripts..."
sudo cp "$(dirname "$0")/azure_helper.sh" /opt/scripts/
sudo cp "$(dirname "$0")/orchestrator.sh" /opt/scripts/
sudo cp "$(dirname "$0")/remediation.sh"  /opt/scripts/
sudo chmod +x /opt/scripts/*.sh

echo "[INFO] Installing cron jobs..."
crontab -r 2>/dev/null || true
(crontab -l 2>/dev/null; echo "* * * * * /opt/scripts/orchestrator.sh") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * sleep 30 && /opt/scripts/orchestrator.sh") | crontab -

echo "[INFO] Verifying installation..."
echo ""
echo "Scripts installed:"
ls -la /opt/scripts/
echo ""
echo "Cron jobs:"
crontab -l
echo ""
echo "[INFO] Setup completed. Orchestrator will run every 30 seconds."