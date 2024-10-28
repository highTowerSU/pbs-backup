#!/bin/bash

# -----------------------------------------------------------------------------
# remove_no_valid_proxmox.sh
# Copyright (C) 2021-2024 highTowerSU
#
# Repository: https://github.com/highTowerSU/pbs-backup
#
# Description: This script removes the Proxmox Enterprise subscription warning 
# from the Proxmox interface. It modifies configuration files to suppress the 
# alert about missing Enterprise subscriptions, enabling a cleaner user interface 
# without the warning message.
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

sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
for i in pveproxy.service proxmox-backup.service; do
  if systemctl list-units --full -all | grep -Fq $i; then
    systemctl restart $i;
  fi
done
