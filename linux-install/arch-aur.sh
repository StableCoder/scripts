#!/usr/bin/env bash

# Update the makepkg configuration for native architecture and using all CPU threads
sudo sed -i "s/CFLAGS=\"-march=x86-64 -O2 -mtune=generic -pipe -fno-plt\"/CFLAGS=\"-march=native -O3 -pipe -fno-plt\"/g" /etc/makepkg.conf
sudo sed -i "s/CXXFLAGS=\"-march=x86-64 -O2 -mtune=generic -pipe -fno-plt\"/CXXFLAGS=\"-march=native -O3 -pipe -fno-plt\"/g" /etc/makepkg.conf
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g" /etc/makepkg.conf

# AUR
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -si --noconfirm
cd ..
rm -rf pikaur

# AUR Packages
pikaur -S --noconfirm --nodiff --noedit bloaty cmake-format cppreference monofonto renderdoc nordvpn pikaur
