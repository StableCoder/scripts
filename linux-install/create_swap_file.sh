#!/usr/bin/env sh

# Copyright (C) 2021 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# Colours
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

# Exit on any error
set -o errexit

# Settings/Input
printf " ${CYAN}>>${NO_COLOUR} Enter size of the swap file (default: 16G): "
read SWAP_SIZE
SWAP_SIZE="${SWAP_SIZE:-16G}"

# Processing
printf " ${GREEN}>>${NO_COLOUR} Creating file\n"
dd if=/dev/zero of=/swapfile-$SWAP_SIZE bs=1M count=$(numfmt --to=iec --to-unit=Mi --from=iec $SWAP_SIZE)
chmod 600 /swapfile-$SWAP_SIZE

printf " ${GREEN}>>${NO_COLOUR} Setting file as swap\n"
mkswap /swapfile-$SWAP_SIZE
swapon /swapfile-$SWAP_SIZE

printf " ${GREEN}>>${NO_COLOUR} Adding to file system table (fstab)\n"
echo "/swapfile-$SWAP_SIZE swap swap defaults 0 0" >>/etc/fstab
