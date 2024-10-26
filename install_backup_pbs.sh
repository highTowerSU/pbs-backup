#!/bin/bash

# Installationspfade
BACKUP_SCRIPT="/usr/local/bin/backup_pbs.sh"
NOVALID_SCRIPT="/usr/local/bin/remove_no_valid_proxmox.sh"
CONFIG_FILE="/etc/backup_pbs.conf"

# Skript kopieren
echo "Installing backup script to $BACKUP_SCRIPT..."
sudo cp backup_pbs.sh "$BACKUP_SCRIPT"
sudo chmod +x "$BACKUP_SCRIPT"

# Skript kopieren
echo "Installing backup script to $NOVALID_SCRIPT..."
sudo cp remove_no_valid_proxmox.sh "$NOVALID_SCRIPT"
sudo chmod +x "$NOVALID_SCRIPT"

# Konfigurationsdatei kopieren
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Copying configuration file to $CONFIG_FILE..."
    sudo cp backup_pbs.conf "$CONFIG_FILE"
    echo "Please edit $CONFIG_FILE to set up your Proxmox Backup settings."
else
    echo "$CONFIG_FILE already exists. Skipping copy."
fi

echo "Installation complete. Run $BACKUP_SCRIPT to start the backup."
