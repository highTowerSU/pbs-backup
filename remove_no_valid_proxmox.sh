#!/bin/bash
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
for i in pveproxy.service proxmox-backup.service; do
  if systemctl list-units --full -all | grep -Fq ".service"; then
    systemctl restart ;
  fi
done
