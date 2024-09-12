#!/usr/bin/env sh

# Copyright (C) 2022 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

DATE=$1

if [ -z $DATE ]; then
    echo "ERROR: No date specified, call ./undo-pacman-upgrade.sh YYYY-MM-DD"
    exit 1
fi

grep -a upgraded /var/log/pacman.log | grep $DATE >/tmp/lastupdates.txt
awk '{print $4}' /tmp/lastupdates.txt >/tmp/lines1
awk '{print $5}' /tmp/lastupdates.txt | sed 's/(/-/g' >/tmp/lines2
paste /tmp/lines1 /tmp/lines2 >/tmp/lines
tr -d "[:blank:]" </tmp/lines >/tmp/packages
cd /var/cache/pacman/pkg/

for i in $(cat /tmp/packages); do
    echo "FOR: $i"
    sudo pacman --noconfirm -U $(ls "$i"* | grep -v -e "\.sig")
done
