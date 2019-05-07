#!/bin/bash

# AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# AUR Packages
yay -S --noconfirm --nodiffmenu --noeditmenu --noupgrademenu --afterclean monofonto remmina-plugin-rdesktop conan protonmail-bridge renderdoc
