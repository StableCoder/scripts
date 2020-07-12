#!/usr/bin/env bash

# AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# AUR Packages
yay -S --noconfirm --nodiffmenu --noeditmenu --noupgrademenu --afterclean bloaty monofonto renderdoc nordvpn yay
