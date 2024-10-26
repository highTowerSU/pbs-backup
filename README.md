# Backup Script for Proxmox and Proxmox Backup

This script automates the backup of Proxmox data to a designated Proxmox Backup Server (PBS).

## Requirements

- Proxmox Backup Client installed
- Configuration file located at `/etc/backup_pbs.conf` with necessary environment variables

## Installation

1. **Clone the repository** and navigate to the project folder:
   ```bash
   git clone https://github.com/highTowerSU/pbs-backup.git
   cd pbs-backup
   ```

2. **Run the installation script** to copy files to the appropriate locations:
   ```bash
   sudo bash install_backup_pbs.sh
   ```
   This will:
   - Copy the main script to `/usr/local/bin/backup_pbs.sh`
   - Copy the configuration file to `/etc/backup_pbs.conf` if it doesn't already exist.

3. **Edit the configuration file**:
   Open `/etc/backup_pbs.conf` and set your Proxmox Backup Server details:
   ```plaintext
   PBS_PASSWORD='your_password_here'
   PBS_FINGERPRINT='your_fingerprint_here'
   PBS_REPOSITORY='user@server@hostname:backup'
   PBS_NS='your_namespace_here'
   PBS_ARCHIVES='root.pxar:/ c.pxar:/mnt/c/'
   ```

## Usage

Run the script manually or set it up as a cron job for regular automated backups.

```bash
# Manual run
/usr/local/bin/backup_pbs.sh
```

Add to cron:
```plaintext
30 23 * * * /usr/local/bin/backup_pbs.sh
```

### Exclusions for WSL

If you're running this on WSL, you may want to exclude the following directories. To do so, create a file at `/.pxarexclude` with the following content:

```plaintext
/proc/
/sys/
```

## Troubleshooting Installation

If the Proxmox Backup Client (`proxmox-backup-client`) is not installed, run the following commands:

```bash
sudo apt update
sudo apt install proxmox-backup-client
```

If you encounter repository issues, create the file `/etc/apt/sources.list.d/proxmox-backup-client.list` with the following content:

```plaintext
deb http://download.proxmox.com/debian/pbs bullseye main
```

Then update your package list again with:
```bash
sudo apt update
```

