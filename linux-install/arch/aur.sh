#!/usr/bin/env bash

# Copyright (C) 2022 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# Colours
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
DEFAULT='\033[0m'
NO_COLOUR='\033[0m'

# Functions
confirm() {
    printf "${1:-Are you sure? [y/N]} "
    read -r -p "" response
    case "$response" in
    [yY][eE][sS] | [yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

# Update the makepkg configuration for native architecture and using all CPU threads
sudo sed -i "s/CFLAGS=\"-march=x86-64 -O2 -mtune=generic -pipe -fno-plt\"/CFLAGS=\"-march=native -O3 -pipe -fno-plt\"/g" /etc/makepkg.conf
sudo sed -i "s/CXXFLAGS=\"-march=x86-64 -O2 -mtune=generic -pipe -fno-plt\"/CXXFLAGS=\"-march=native -O3 -pipe -fno-plt\"/g" /etc/makepkg.conf
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g" /etc/makepkg.conf

# Make/install Pikaur
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -si --noconfirm
cd ..
rm -rf pikaur

# Dev Packages
if confirm " ${CYAN}>>${NO_COLOUR} Install development items? [y/N]"; then
    pikaur -S --noconfirm --nodiff --noedit bloaty cmake-format cppreference renderdoc
fi

# UI
if confirm " ${CYAN}>>${NO_COLOUR} Install monofonto? [y/N]"; then
    pikaur -S --noconfirm --nodiff --noedit monofonto
fi
