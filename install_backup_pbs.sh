#!/bin/bash

# Installationspfade
BACKUP_SCRIPT="/usr/local/bin/backup_pbs.sh"
NOVALID_SCRIPT="/usr/local/bin/remove_no_valid_proxmox.sh"
SYMLINK_PATH="/etc/cron.daily/remove-no-valid-proxmox"
CONFIG_FILE="/etc/backup_pbs.conf"

# Skript kopieren
echo "Installing backup script to $BACKUP_SCRIPT..."
sudo cp backup_pbs.sh "$BACKUP_SCRIPT"
sudo chmod +x "$BACKUP_SCRIPT"

# Abfrage, ob das Skript novalid installiert werden soll
echo "Do you want to install novalid script? (y/n): "
read install_novalid
if [[ "$install_novalid" == "y" || "$install_novalid" == "Y" ]]; then
    # Skript kopieren
    echo "Installing novalid script to $NOVALID_SCRIPT..."
    sudo cp remove_no_valid_proxmox.sh "$NOVALID_SCRIPT"
    sudo chmod +x "$NOVALID_SCRIPT"

    # Abfrage, ob der Symlink erstellt werden soll
    echo "Do you want to create a symlink for daily cron? (y/n): "
    read create_symlink
    if [[ "$create_symlink" == "y" || "$create_symlink" == "Y" ]]; then
        echo "Creating symlink at $SYMLINK_PATH..."
        ln -sf "$NOVALID_SCRIPT" "$SYMLINK_PATH"
        echo "Symlink created."
    else
        echo "Symlink creation skipped."
    fi
else
    echo "Install novalid script skipped."
fi

# Konfigurationsdatei kopieren
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Copying configuration file to $CONFIG_FILE..."
    sudo cp backup_pbs.conf "$CONFIG_FILE"
    echo "Please edit $CONFIG_FILE to set up your Proxmox Backup settings."
else
    echo "$CONFIG_FILE already exists. Skipping copy."
fi

echo "Installation complete. Run $BACKUP_SCRIPT to start the backup."
