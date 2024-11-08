#!/bin/bash

# -----------------------------------------------------------------------------
# pbs_ad_sync.sh
# Copyright (C) 2021-2024 highTowerSU
#
# Repository: https://github.com/highTowerSU/pbs-backup
#
# Description: Synchronizes users with a Proxmox Backup Server and assigns admin rights to specific users.
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
CONFIG_PATH=/etc/pbs_ad_sync.conf
NOSYNC=false
NOACLS=false

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
    echo "  -a, --no-acls             Do not add ad users as admin"
    echo "  -b, --noninteractive      Run in non-interactive mode"
    echo "  -q, --quiet               Show only error messages"
    echo "  -n, --no-sync             Do not sync ad users"
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
        -a|--no-acls)
            NOSYNC=true
            shift
            ;;
        -b|--noninteractive)
            NONINTERACTIVE=true
            shift
            ;;
        -n|--no-sync)
            NOSYNC=true
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

# Überprüfung, ob proxmox-backup-manager installiert ist
if ! command -v proxmox-backup-manager >/dev/null 2>&1; then
    cat <<EOF
Error: proxmox-backup-manager is not installed. Please install it before running this script.
EOF
    exit 1
fi

# Überprüfung, ob jq installiert ist
if ! command -v jq >/dev/null 2>&1; then
    cat <<EOF
Error: jq is not installed. Please install jq before running this script.
EOF
    exit 1
fi

# Interaktive Abfrage zur Synchronisation und ACL-Zuweisung
if ! $NONINTERACTIVE; then
    if ! $NOSYNC; then
        echo -n "Do you want to perform an Active Directory synchronization now? (y/n): "
        read sync_ad_answer
        if [[ "$sync_ad_answer" != "y" && "$sync_ad_answer" != "Y" ]]; then
            NOSYNC=true
            echo "AD synchronization skipped."
        fi
    fi

    if ! $NOACLS && ! $NOSYNC; then
        echo -n "Do you want to assign Admin role to AD users now? (y/n): "
        read acl_answer
        if [[ "$acl_answer" != "y" && "$acl_answer" != "Y" ]]; then
            NOACLS=true
            echo "Admin role assignment skipped."
        fi
    fi
fi

# Synchronisation und/oder ACL-Zuweisung durchführen, falls nicht übersprungen
if ! $NOSYNC; then
    echo "Synchronizing with Active Directory..."
    proxmox-backup-manager ad sync "${AD_DOMAIN}"
    echo "Synchronization complete."
fi

if ! $NOACLS && ! $NOSYNC; then
    # Benutzerliste abrufen und filtern
    users_json=$(proxmox-backup-manager user list --output-format json-pretty)
    user_ids=$(echo "$users_json" | jq -r --arg domain "@$AD_DOMAIN" '.[] | select(.userid | endswith(@$AD_DOMAIN)) | .userid')

    # Admin-Rolle für jeden Benutzer zuweisen
    while IFS= read -r userid; do
        if [[ -n "$userid" ]]; then
            echo "Assigning Admin role to user: $userid"
            proxmox-backup-manager acl update / Admin --auth-id "$userid"
        fi
    done <<< "$user_ids"

    echo "Admin role assigned to all matching users."
fi
