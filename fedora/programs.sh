#!/usr/bin/env bash
set -e

# Update the lists
dnf update -y

# Development

## Base Compilers
dnf install -y gcc gcc-c++ gdb clang lld lldb rust go llvm llvm-libs
## Dev Support Tools
dnf install -y git git-lfs subversion make ninja-build cmake doxygen graphviz
## Analysis
dnf install -y libasan liblsan libtsan libubsan clang-tools-extra iwyu cppcheck
## Editors
dnf install -y vim kate

## VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf install -y code

# Virtualization
dnf install -y docker libvirt virt-manager qemu qemu-kvm docker-compose qemu-block-gluster

systemctl start libvirtd
systemctl start docker

virsh net-autostart default

usermod -aG docker $(whoami)
usermod -aG libvirt $(whoami)

systemctl stop docker
systemctl stop libvirtd

# Other Applications
dnf install -y clementine awscli youtube-dl keepassxc openssh rsync remmina freerdp rdesktop remmina-plugins-rdp cool-retro-term ufw
dnf install -y libreoffice firefox thunderbird

# Development Libraries
dnf install -y assimp-devel bullet-devel vulkan-devel portaudio-devel glfw-devel glm-devel catch-devel freeimage-devel yaml-cpp-devel 