#!/bin/bash

# -----------------------------------------------------------------------------
# backup_pbs.sh
# Copyright (C) 2021-2024 highTowerSU
#
# Repository: https://github.com/highTowerSU/pbs-backup
#
# Description: This script backs up specified directories to a Proxmox Backup Server.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------

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
    # Backup starten
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
