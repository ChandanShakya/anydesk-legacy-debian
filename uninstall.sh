#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run as a normal user."
    exit 1
fi

sudo systemctl disable --now anydesk.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/anydesk.service
sudo systemctl daemon-reload 2>/dev/null || true
sudo apt-get purge -y anydesk

echo "AnyDesk removed."
echo "Compatibility libraries were retained."
