#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
DEFAULT='\033[0m'
NO_COLOUR='\033[0m'

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

# sudo
confirm " ${CYAN}>>${NO_COLOUR} Install sudo? [y/N]" && export SUDO=1
if [[ $SUDO -eq 1 ]]; then
    pacman -S --noconfirm sudo

    echo -n -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be added to 'wheel' group:"
    read -s -r USER_LIST
    for USER in $USER_LIST; do
        usermod -aG wheel $USER
    done
    echo
fi

# Development
confirm " ${CYAN}>>${NO_COLOUR} Setup development tools? [y/N]" && export DEV_TOOLS=1
if [[ $DEV_TOOLS -eq 1 ]]; then
    # Base Compilers
    pacman -S --noconfirm base-devel gcc clang llvm gdb lldb lld python go rust
    # Dev Support Tools
    pacman -S --noconfirm doxygen cppcheck valgrind massif-visualizer git git-lfs subversion cmake make ninja graphviz python-pip meson
    # Editors
    pacman -S --noconfirm code vim kate
fi

# Gamedev
confirm " ${CYAN}>>${NO_COLOUR} Setup development tools? [y/N]" && export GAMEDEV=1
if [[ $GAMEDEV -eq 1 ]]; then
    pacman -S --noconfirm assimp portaudio bullet vulkan-devel fmt glm glfw freeimage catch2 libyaml yaml-cpp
fi

# Virtualization
DOIT=0
confirm " ${CYAN}>>${NO_COLOUR} Setup virtualization/docker? [y/N]" && export DOIT=1
if [[ $DOIT -eq 1 ]]; then
    echo -e " ${GREEN}>>${NO_COLOUR} iptables-nft will need to replace iptables, and will request permission to do so:"
    pacman -S iptables-nft
    pacman -S --noconfirm docker docker-compose libvirt virt-manager qemu qemu-arch-extra qemu-block-gluster glusterfs ebtables dnsmasq edk2-ovmf

    systemctl start libvirtd
    systemctl start docker

    virsh net-autostart default

    echo -n -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be added to 'docker' group:"
    read -s -r USER_LIST
    for USER in $USER_LIST; do
        usermod -aG docker $USER
    done
    echo

    echo -n -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be added to 'libvirt' group:"
    read -s -r USER_LIST
    for USER in $USER_LIST; do
        usermod -aG libvirt $USER
    done
    echo
fi

# Personalization
confirm " ${CYAN}>>${NO_COLOUR} Enable Multilib (for Steam)? [y/N]" && export INSTALLMULTILIB=1
if [ "$INSTALLMULTILIB" == 1 ]; then
    CONFLINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d':' -f1)
    sed -i "${CONFLINE}s/#\[multilib\]/\[multilib\]/" /etc/pacman.conf
    CONFLINE=$((CONFLINE + 1))
    sed -i "${CONFLINE}s/.*/Include = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
    pacman -Syu

    confirm " ${CYAN}>>${NO_COLOUR} Install Steam? [y/N]" && export INSTALLSTEAM=1
    if [ "$INSTALLSTEAM" == 1 ]; then
        pacman -S --noconfirm steam
    fi
fi

confirm " ${CYAN}>>${NO_COLOUR} Install KDE Plasma DE? [y/N]" && export INSTALLKDE=1
if [ "$INSTALLKDE" == 1 ]; then
    pacman -S --noconfirm plasma kdeplasma-addons papirus-icon-theme ffmpegthumbs ark kimageformats qt5-imageformats qt6-imageformats
    pacman -Rs --noconfirm discover

    confirm " ${CYAN}>>${NO_COLOUR} Enable SDDM? [y/N]" && export ENABLE_SDDM=1
    if [ "$ENABLE_SDDM" == 1 ]; then
        systemctl enable sddm
    fi
fi

confirm " ${CYAN}>>${NO_COLOUR} Install Deepin DE? [y/N]" && export INSTALLDEEPIN=1
if [ "$INSTALLDEEPIN" == 1 ]; then
    pacman -S --noconfirm deepin papirus-icon-theme
fi

confirm " ${CYAN}>>${NO_COLOUR} Install i3 DE? [y/N]" && export INSTALLI3=1
if [ "$INSTALLI3" == 1 ]; then
    pacman -S --noconfirm i3-gaps i3status i3lock feh dmenu xbacklight
fi

confirm " ${CYAN}>>${NO_COLOUR} Install Syncthing? [y/N]" && export SYNCTHING=1
if [ "$SYNCTHING" == 1 ]; then
    pacman -S --noconfirm syncthing
fi

# Other Applications
pacman -S --noconfirm dolphin konsole cool-retro-term openssh keepassxc rdesktop python-pyopenssl youtube-dl ufw traceroute remmina rsync zip aws-cli htop usbutils
# Media
pacman -S --noconfirm clementine elisa eog gwenview vlc gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gstreamer-vaapi
# Archivers
pacman -S --noconfirm p7zip unrar unarchiver lzop lrzip
# Productivity
pacman -S --noconfirm firefox libreoffice-fresh blender okular
# Fonts
pacman -S --noconfirm awesome-terminal-fonts powerline-fonts
# Streaming
pacman -S --noconfirm obs-studio
# Video Editing
pacman -S kdenlive mlt