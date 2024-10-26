#!/bin/bash

PBS_PASSWORD='your_password_here'
PBS_FINGERPRINT='your_fingerprint_here'
PBS_REPOSITORY='user@server@hostname:backup'
PBS_NS='your_namespace_here'
PBS_ARCHIVES='root.pxar:/ c.pxar:/mnt/c/'

export PBS_REPOSITORY
export PBS_PASSWORD
export PBS_FINGERPRINT

proxmox-backup-client login
proxmox-backup-client backup $PBS_ARCHIVES --ns "$PBS_NS"
