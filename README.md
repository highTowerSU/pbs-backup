# Backup Script for Proxmox and Proxmox Backup

This script automates the backup of Proxmox data to a designated Proxmox Backup Server (PBS).

## Requirements

- Proxmox Backup Client installed
- Necessary environment variables configured in the script

## Usage

Run the script manually or set it up as a cron job for regular automated backups.

```
# Manual run
./backup_pbs.sh
```

Add to cron:
```
30 23 * * * /usr/local/bin/backup_pbs.sh
```

### Exclusions for WSL

If you're running this on WSL, you may want to exclude the following directories:
nano /.pxarexclude

```
/proc/
/sys/
```
