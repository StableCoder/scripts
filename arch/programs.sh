#!/usr/bin/env bash
set -e

RED='\033[0;31m'
DEFAULT='\033[0m'

if [ $SUDO_USER ]; then user=$SUDO_USER; else user=$(whoami); fi
if [ "$user" == "root" ] || [ "$user" == "" ]; then
    echo -e "${RED}Don't run this as root! Create a user and use as them to setup docker/libvirt bindings.${DEFAULT}"
    exit 1
fi

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
    [yY][eE][sS] | [yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

# Development

## Base Compilers
pacman -S --noconfirm base-devel gcc clang llvm gdb lldb lld python go rust
## Dev Support Tools
pacman -S --noconfirm doxygen cppcheck valgrind massif-visualizer git git-lfs subversion cmake make ninja graphviz
## Editors
pacman -S --noconfirm code vim kate

# Virtualization
pacman -S --noconfirm qemu docker docker-compose libvirt virt-manager qemu-block-gluster glusterfs ebtables dnsmasq edk2-ovmf

systemctl start libvirtd
systemctl start docker

usermod -aG docker $(whoami)
usermod -aG libvirt $(whoami)

virsh net-autostart default

# Other Applications
pacman -S --noconfirm dolphin konsole cool-retro-term openssh clementine keepassxc rdesktop python-pyopenssl youtube-dl ufw traceroute remmina rsync zip aws-cli eog gwenview vlc htop
# GStreamer plugins
pacman -S --noconfirm gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gstreamer-vaapi
# Productivity
pacman -S --noconfirm firefox libreoffice-fresh blender
# Fonts
pacman -S --noconfirm awesome-terminal-fonts powerline-fonts

# Development Libaries
pacman -S --noconfirm assimp portaudio bullet vulkan-devel fmt glm glfw freeimage catch2 libyaml yaml-cpp

# Personalization
confirm "Enable Multilib (for Steam)? [y/N]" && export INSTALLMULTILIB=1
if [ "$INSTALLMULTILIB" == 1 ]; then
    CONFLINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d':' -f1)
    sudo sed -i "${CONFLINE}s/#\[multilib\]/\[multilib\]/" /etc/pacman.conf
    CONFLINE=$((CONFLINE + 1))
    sudo sed -i "${CONFLINE}s/.*/Include = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
    pacman -Syu
fi

confirm "Install KDE Plasma DE? [y/N]" && export INSTALLKDE=1
if [ "$INSTALLKDE" == 1 ]; then
    pacman -S --noconfirm plasma kdeplasma-addons papirus-icon-theme ffmpegthumbs
    pacman -Rs --noconfirm discover
fi

confirm "Install Deepin DE? [y/N]" && export INSTALLDEEPIN=1
if [ "$INSTALLDEEPIN" == 1 ]; then
    pacman -S --noconfirm deepin papirus-icon-theme
fi

confirm "Install i3 DE? [y/N]" && export INSTALLI3=1
if [ "$INSTALLI3" == 1 ]; then
    pacman -S --noconfirm i3-gaps i3status i3lock feh dmenu xbacklight
fi
