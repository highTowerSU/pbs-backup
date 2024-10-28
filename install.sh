#!/bin/bash

# -----------------------------------------------------------------------------
# install_backup_pbs.sh
# Copyright (C) 2021-2024 highTowerSU
#
# Repository: https://github.com/highTowerSU/pbs-backup
#
# Description: This script installs the backup script for Proxmox and its 
# configuration files. It places the backup script in the appropriate directory 
# (`/usr/local/bin`), creates a configuration file in `/etc/`, and offers to 
# modify SSH settings as needed. Non-interactive mode is supported via 
# the `--noninteractive` parameter.
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

# Installationspfade
BACKUP_SCRIPT="/usr/local/bin/backup_pbs.sh"
NOVALID_SCRIPT="/usr/local/bin/remove_no_valid_proxmox.sh"
SYMLINK_PATH="/etc/cron.daily/remove-no-valid-proxmox"
CONFIG_FILE="/etc/backup_pbs.conf"
CRON_FILE="/etc/cron.d/backup_pbs"


# Standard-Parameter
NONINTERACTIVE=false
NOVALID=false
CRON=false
BACKUP_CRON=false
BACKUP_CRON_TIME="30 23 * * *"

# Hilfe anzeigen
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                  Show this help message and exit"
    echo "  -b, --backup-cron           Set up a cron job for backup script"
    echo "  -c, --backup-cron-time      Set up a cron job for backup script at <23 30 * * *>"
    echo "  -n, --noninteractive        Run in non-interactive mode"
    echo "  -v, --cron-novalid          Set up a cron job for regular execution"
    echo "  -w, --with-novalid-warning  'Skip Proxmox enterprise warning' script installation"
    echo ""
    echo "Example:"
    echo "  $0 --noninteractive --backup-cron --backup-cron-time <'23 30 * * *'> --with-novalid-warning --cron-novalid"
}

# Argumente parsen
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup-cron)
            BACKUP_CRON=true
            shift
            ;;
        -c|--backup-cron-time)
            BACKUP_CRON_TIME=$2
            shift 2
            ;;
        -n|--noninteractive)
            NONINTERACTIVE=true
            shift
            echo "switched to noninteractive-Mode"
            ;;
        -v|--cron-novalid)
            CRON=true
            shift
            ;;
        -w|--with-novalid-warning)
            NOVALID=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Skript kopieren
echo "Installing backup script to $BACKUP_SCRIPT..."
sudo cp backup_pbs.sh "$BACKUP_SCRIPT"
sudo chmod +x "$BACKUP_SCRIPT"

# Konfigurationsdatei kopieren
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Copying configuration file to $CONFIG_FILE..."
    sudo cp backup_pbs.conf "$CONFIG_FILE"
    echo "Please edit $CONFIG_FILE to set up your Proxmox Backup settings."
else
    echo "$CONFIG_FILE already exists. Skipping copy."
fi
echo "Copying configuration template to ${CONFIG_FILE}.dist..."
cp backup_pbs.conf "${CONFIG_PATH}.dist"

set_backup_cron=false
if $BACKUP_CRON; then
    set_backup_cron=true
elif ! $NONINTERACTIVE; then
    echo -n "Do you want to create a cron job for backup script? (y/N): "
    read backup_cron_response
    if [[ "$backup_cron_response" == "y" || "$backup_cron_response" == "Y" ]]; then
        set_backup_cron=true
    fi
fi

if $set_backup_cron; then
    echo "Setting up cron job for backup script at $CRON_FILE..."
    echo "$BACKUP_CRON_TIME root $BACKUP_SCRIPT -q" | sudo tee "$CRON_FILE" > /dev/null
    echo "Backup cron job created."
else
    echo "Backup cron job creation skipped."
fi

# Prüfen, ob --novalid gesetzt ist oder interaktiv nachfragen
install_novalid=false
if $NOVALID; then
    install_novalid=true
elif ! $NONINTERACTIVE; then
    echo -n "Do you want to install the novalid script? (y/N): "
    read install_novalid_response
    if [[ "$install_novalid_response" == "y" || "$install_novalid_response" == "Y" ]]; then
        install_novalid=true
    fi
fi

if $install_novalid; then
    echo "Installing novalid script to $NOVALID_SCRIPT..."
    sudo cp remove_no_valid_proxmox.sh "$NOVALID_SCRIPT"
    sudo chmod +x "$NOVALID_SCRIPT"

    # Prüfen auf --cron oder interaktiv nachfragen für den Symlink
    create_symlink=false
    if $CRON; then
        create_symlink=true
    elif ! $NONINTERACTIVE; then
        echo -n "Do you want to create a symlink for daily cron? (y/N): "
        read create_symlink_response
        if [[ "$create_symlink_response" == "y" || "$create_symlink_response" == "Y" ]]; then
            create_symlink=true
        fi
    fi

    if $create_symlink; then
        echo "Creating symlink at $SYMLINK_PATH..."
        ln -sf "$NOVALID_SCRIPT" "$SYMLINK_PATH"
        echo "Symlink created."
    else
        echo "Symlink creation skipped."
    fi
else
    echo "Install novalid script skipped."
fi

echo "Installation complete. Run $BACKUP_SCRIPT to start the backup."
