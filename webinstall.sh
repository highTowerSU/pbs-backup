#!/bin/bash

# -----------------------------------------------------------------------------
# webinstall.sh
# Copyright (C) 2021-2024 highTowerSU
#
# Repository: https://github.com/highTowerSU/pbs-backup
#
# Description: installs backup pbs and no banner script, supports optional cron setup 
#              and non-interactive mode.
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

# Überprüfen, ob git installiert ist
if ! command -v git > /dev/null; then
    echo "Git is not installed. Attempting to install..."
    if command -v apt > /dev/null; then
        sudo apt update
        sudo apt install -y git
    else
        echo "Error: Package manager not supported or git could not be installed."
        exit 1
    fi
fi

# Temporäres Verzeichnis erstellen und Repository klonen
TEMP_DIR=$(mktemp -d)
git clone https://github.com/highTowerSU/pbs-backup.git "$TEMP_DIR"

# Sicherstellen, dass install.sh existiert und ausführbar ist
if [ -f "$TEMP_DIR/install.sh" ]; then
    chmod +x "$TEMP_DIR/install.sh"
    cd $TEMP_DIR
    echo "running: ./install.sh $@"
    "./install.sh" "$@"
    cd ..
else
    echo "Error: install.sh not found in the repository."
    exit 1
fi

# Aufräumen
rm -rf "$TEMP_DIR"
