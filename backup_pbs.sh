#!/bin/bash

# Author: highTowerSU
# License: AGPL 3.0
# Description: This script backs up specified directories to a Proxmox Backup Server.

# Konfigurationsdatei laden
if [ -f /etc/backup_pbs.conf ]; then
    source /etc/backup_pbs.conf
else
    echo "Error: Configuration file /etc/backup_pbs.conf not found."
    exit 1
fi

export PBS_REPOSITORY
export PBS_PASSWORD
export PBS_FINGERPRINT

# Überprüfung, ob das Backup-Tool installiert ist
if command -v proxmox-backup-client >/dev/null 2>&1; then
    # Backup starten, falls das Tool vorhanden ist
    proxmox-backup-client login
    proxmox-backup-client backup $PBS_ARCHIVES --ns "$PBS_NS"
else
    # Fehlermeldung anzeigen, falls das Tool fehlt
    cat <<EOF
Error: proxmox-backup-client is not installed. Please install it before running this script.

To install on Debian-based systems, use:
  sudo apt update
  sudo apt install proxmox-backup-client

If you encounter issues with the repository, create the following file:

  sudo nano /etc/apt/sources.list.d/proxmox-backup-client.list

Add the following line to enable the Proxmox Backup repository:

  deb http://download.proxmox.com/debian/pbs bullseye main

Then update your package list again with:
  sudo apt update
EOF
    exit 1
fi
