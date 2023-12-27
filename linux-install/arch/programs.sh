#!/usr/bin/env bash
set -e

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

# User creation
echo -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be created:"
read -r USER_LIST
for USER in $USER_LIST; do
    useradd -m $USER
done
echo

# sudo
if confirm " ${CYAN}>>${NO_COLOUR} Install sudo? [y/N]"; then
    pacman -S --noconfirm sudo

    echo -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be added to 'wheel' group:"
    read -r USER_LIST
    for USER in $USER_LIST; do
        usermod -aG wheel $USER
    done
    echo

    # Enable sudo for wheel group
    sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
fi

# Development
if confirm " ${CYAN}>>${NO_COLOUR} Install development tools? [y/N]"; then
    # Base Compilers
    pacman -S --noconfirm base-devel gcc clang llvm gdb lldb lld python go rust
    # Dev Support Tools
    pacman -S --noconfirm doxygen cppcheck valgrind massif-visualizer git git-lfs subversion cmake make ninja graphviz python-pip meson
    # Editors
    pacman -S --noconfirm code vim kate
fi

# Gamedev
if confirm " ${CYAN}>>${NO_COLOUR} Install FoE game development libraries? [y/N]"; then
    pacman -S --noconfirm assimp portaudio bullet vulkan-devel fmt glm glfw freeimage catch2 libyaml yaml-cpp openxr
fi

# Virtualization/Containers
if confirm " ${CYAN}>>${NO_COLOUR} Setup virtualization? [y/N]"; then
    echo -e " ${GREEN}>>${NO_COLOUR} iptables-nft will need to replace iptables, and will request permission to do so."
    pacman -S iptables-nft
    pacman -S --noconfirm libvirt virt-manager qemu qemu-arch-extra qemu-block-gluster glusterfs ebtables dnsmasq edk2-ovmf swtpm

    systemctl start libvirtd

    virsh net-autostart default

    echo -e " ${CYAN}>>${NO_COLOUR} Enter set of users to be added to 'libvirt' group:"
    read -r USER_LIST
    for USER in $USER_LIST; do
        usermod -aG libvirt $USER
    done
    echo
fi

if confirm " ${CYAN}>>${NO_COLOUR} Setup containers? [y/N]"; then
    pacman -S --noconfirm buildah podman podman-compose qemu-user-static qemu-user-static-binfmt qemu-block-gluster glusterfs

    echo -e " ${CYAN}>>${NO_COLOUR} Enter set of users that will use containers:"
    read -r USER_LIST
    COUNT=1
    for USER in $USER_LIST; do
        usermod --add-subuids ${COUNT}00000-${COUNT}65535 --add-subgids ${COUNT}00000-${COUNT}65535 $USER
        ((COUNT++))
    done
    podman system migrate
    echo
fi

# Personalization
if confirm " ${CYAN}>>${NO_COLOUR} Enable Multilib (for Steam)? [y/N]"; then
    CONFLINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d':' -f1)
    sed -i "${CONFLINE}s/#\[multilib\]/\[multilib\]/" /etc/pacman.conf
    CONFLINE=$((CONFLINE + 1))
    sed -i "${CONFLINE}s/.*/Include = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
    pacman -Syu

    if [ "$INSTALLSTEAM" == 1 ]; then
        pacman -S --noconfirm steam
    fi
fi

# Desktop Environments
if confirm " ${CYAN}>>${NO_COLOUR} Install KDE Plasma DE? [y/N]"; then
    # KDE
    pacman -S --noconfirm plasma plasma-wayland-session kdeplasma-addons papirus-icon-theme ffmpegthumbs ark kimageformats qt5-imageformats qt6-imageformats spectacle
    pacman -Rs --noconfirm discover

    if confirm " ${CYAN}>>${NO_COLOUR} Enable SDDM? [y/N]"; then
        systemctl enable sddm
    fi
fi
if confirm " ${CYAN}>>${NO_COLOUR} Install i3 DE? [y/N]"; then
    # i3
    pacman -S --noconfirm i3-gaps i3status i3lock feh dmenu xbacklight
fi

# Syncthing
if confirm " ${CYAN}>>${NO_COLOUR} Install Syncthing? [y/N]"; then
    pacman -S --noconfirm syncthing
fi

# Media applications / audio codecs / plugins
if confirm " ${CYAN}>>${NO_COLOUR} Install media applications/audio codecs? [y/N]"; then
    pacman -S --noconfirm elisa eog gwenview vlc gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gstreamer-vaapi
fi

# Productivity
if confirm " ${CYAN}>>${NO_COLOUR} Install LibreOffice/Blender? [y/N]"; then
    pacman -S --noconfirm libreoffice-fresh blender
fi

# Streaming
if confirm " ${CYAN}>>${NO_COLOUR} Install OBS? [y/N]"; then
    pacman -S --noconfirm obs-studio
fi

# Video Editing/Processing
if confirm " ${CYAN}>>${NO_COLOUR} Install video editing/processing? [y/N]"; then
    pacman -S --noconfirm kdenlive mlt rtaudio sox movit rubberband sdl opencv
fi

# Fonts
if confirm " ${CYAN}>>${NO_COLOUR} Install fonts? [y/N]"; then
    pacman -S --noconfirm awesome-terminal-fonts powerline-fonts
fi
# Other Applications
if confirm " ${CYAN}>>${NO_COLOUR} Install other GUI applications? [y/N]"; then
    pacman -S --noconfirm okular firefox dolphin konsole cool-retro-term keepassxc rdesktop python-pyopenssl yt-dlp ufw remminaaws-cli
fi
pacman -S --noconfirm openssh traceroute rsync htop usbutils

# Archivers
pacman -S --noconfirm p7zip unrar unarchiver lzop lrzip zip
