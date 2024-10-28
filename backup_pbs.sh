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

PBS_LOG="info"
NONINTERACTIVE=false
QUIET=false
CONFIG_PATH=/etc/backup_pbs.conf

# Konfigurationsdatei laden
if [ -f "$CONFIG_PATH" ]; then
    source "$CONFIG_PATH"
else
    echo "Error: Configuration file $CONFIG_PATH not found."
    exit 1
fi

# Hilfe anzeigen
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
#    echo "  -b, --noninteractive      Run in non-interactive mode"
    echo "  -q, --quiet               Show only error messages"
    echo ""
    echo "Example:"
    echo "  $0 --noninteractive --modify-sshd-conf"
}

# Argumente parsen
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--noninteractive)
            NONINTERACTIVE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >/dev/stderr
            show_help >/dev/stderr
            exit 1
            ;;
    esac
done

if $QUIET; then
    exec > /dev/null
    PBS_LOG="error"
fi

export PBS_LOG
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
