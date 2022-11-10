#!/bin/env bash

# Exit on any error
set -o errexit

# Colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

# Functions
print_usage() {
    echo "Usage: "
    echo "   arch-base.sh [OPTIONS...]"
    echo ""
    echo "   Options:"
    echo "     -e, --esp  <DEV> Partition to use for EFI boot data"
    echo "     -o, --os   <DEV> Partition to install the OS on"
    echo "     -s, --swap <DEV> Partition to use as SWAP"
}

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

# Environment Variables
EFI_DRIVE=
OS_DRIVE=
SWAP_DRIVE=

# Command-Line Parsing
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -e | --esp)
        EFI_DRIVE=$2
        shift
        shift
        ;;
    -o | --os)
        OS_DRIVE=$2
        shift
        shift
        ;;
    -s | --swap)
        SWAP_DRIVE=$2
        shift
        shift
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done

# Input checks
if [ -z "$EFI_DRIVE" ] || [ ! -b "$EFI_DRIVE" ]; then
    echo -e " ${RED}>> ERROR${NO_COLOUR}: Need to provide partition to install EFI/bootloader"
    ERROR=1
fi
if [ -z "$OS_DRIVE" ] || [ ! -b "$OS_DRIVE" ]; then
    echo -e " ${RED}>> ERROR${NO_COLOUR}: Need to provide partition to install OS"
    ERROR=1
fi
if [ ! -z "$SWAP_DRIVE" ] && [ ! -b "$SWAP_DRIVE" ]; then
    echo -e " ${RED}>> ERROR${NO_COLOUR}: Provided swap partition doesn't exist"
    ERROR=1
fi
if [ ! -z $ERROR ]; then
    exit 1
fi

# Prepare EFI
echo -e " ${GREEN}>>${NO_COLOUR} Setting up EFI partition ($EFI_DRIVE)"
mkdir -p /efi_temp
FS_TYPE=$(blkid -s TYPE $EFI_DRIVE)
if [ -z "$FS_TYPE" ]; then
    mkfs.fat -F32 $EFI_DRIVE
    mount $EFI_DRIVE /efi_temp
    bootctl --path=/efi_temp install
else
    mount $EFI_DRIVE /efi_temp
fi

# Prepare Swap
if [ ! -z "$SWAP_DRIVE" ]; then
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up Swap partition ($SWAP_DRIVE)"
    FS_TYPE=$(blkid -s TYPE $SWAP_DRIVE)
    if [ -z "$FS_TYPE" ]; then
        mkswap $SWAP_DRIVE
    fi
    swapon $SWAP_DRIVE
fi

format_drive() {
    echo " >> Formatting $OS_DRIVE"
    echo -n -e " ${CYAN}>>${NO_COLOUR} Are you sure? Type \"YES\" to confirm: "
    _CONFIRM=""
    read _CONFIRM
    if [ "$_CONFIRM" != "YES" ]; then exit 1; fi

    printf " ${CYAN}>>${NO_COLOUR} Number if iterations to shred the drive (default: 1): "
    read SHRED_ITERATIONS
    SHRED_ITERATIONS="${SHRED_ITERATIONS-1}"

    # Collect Setup params
    ENCRYPT_DRIVE=1
    confirm " ${CYAN}>>${NO_COLOUR} Skip encrypting the drive? [y/N]" && export ENCRYPT_DRIVE=
    if [ ! -z $ENCRYPT_DRIVE ]; then
        DISK_PASSWORD=""
        while [ -z "$DISK_PASSWORD" ]; do
            echo -n -e " ${CYAN}>>${NO_COLOUR} Set DISK Password:"
            read -s -r TEMP_PWORD
            echo
            echo -n -e " ${CYAN}>>${NO_COLOUR} Confirm DISK Password:"
            read -s -r TEMP_PWORD_2
            echo
            if [ "$TEMP_PWORD" == "$TEMP_PWORD_2" ]; then DISK_PASSWORD="$TEMP_PWORD"; fi
        done
    fi
    ROOT_PASSWORD=""
    while [ -z "$ROOT_PASSWORD" ]; do
        echo -n -e " ${CYAN}>>${NO_COLOUR} Set ROOT USER Password:"
        read -s -r TEMP_PWORD
        echo
        echo -n -e " ${CYAN}>>${NO_COLOUR} Confirm ROOT USER Password:"
        read -s -r TEMP_PWORD_2
        echo
        if [ "$TEMP_PWORD" == "$TEMP_PWORD_2" ]; then ROOT_PASSWORD="$TEMP_PWORD"; fi
    done
    HOSTNAME=
    while [ -z "$HOSTNAME" ]; do
        echo -n -e " ${CYAN}>>${NO_COLOUR} Set hostname: "
        read TEMP_HOSTNAME
        if [ -f /efi_temp/loader/entries/$TEMP_HOSTNAME.conf ] || [ -d /efi_temp/installs/$TEMP_HOSTNAME ]; then
            echo -e " ${YELLOW}>>${NO_COLOUR} Given hostname already exists on this machine! (boot loader entry)"
        else
            HOSTNAME=$TEMP_HOSTNAME
        fi
    done
    umount /efi_temp
    echo -n -e " ${CYAN}>>${NO_COLOUR} Set locale [en_US.UTF-8]: "
    read _LOCALE
    _LOCALE="${_LOCALE:-en_US.UTF-8}"
    echo -n -e " ${CYAN}>>${NO_COLOUR} Set timezone [America/Toronto]: "
    read TIMEZONE
    TIMEZONE="${TIMEZONE:-America/Toronto}"
    confirm " ${CYAN}>>${NO_COLOUR} Install NetworkManager for networking? [y/N]" && export INSTALLNM=1
    confirm " ${CYAN}>>${NO_COLOUR} Install Bluetooth support? [y/N]" && export INSTALLBT=1
    confirm " ${CYAN}>>${NO_COLOUR} Change pacman to allow parallel downloads? [y/N]" && export PARALLEL_PACMAN=1

    # Partition Info
    printf " ${CYAN}>>${NO_COLOUR} Enter the LVM volume name (default: STec): "
    read VOL_GROUP
    VOL_GROUP="${VOL_GROUP:-STec}"

    printf " ${CYAN}>>${NO_COLOUR} Enter the %% of free space (#%%FREE) or GB size (50G) of the LVM partition to use for the root filesystem (default: 100%%FREE): "
    read ROOT_SIZE
    ROOT_SIZE="${ROOT_SIZE:-100%FREE}"

    echo -e " ${GREEN}>>${NO_COLOUR} Running..."

    if [[ PARALLEL_PACMAN -eq 1 ]]; then
        # Change the installer medium to also use parallel downloads
        sed -i 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
    fi

    # Wipe and format drive
    echo -e " ${GREEN}>>${NO_COLOUR} Formatting drive ($OS_DRIVE)"
    if [[ $SHRED_ITERATIONS -gt 0 ]]; then
        shred -v -n$SHRED_ITERATIONS "$OS_DRIVE"
    fi

    # Encrypt LVM
    if [ ! -z $ENCRYPT_DRIVE ]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Encrypting main partition"
        cryptsetup luksFormat --type luks2 $OS_DRIVE -q <<<"$DISK_PASSWORD"
        cryptsetup open $OS_DRIVE arch_lvm -q <<<"$DISK_PASSWORD"
        pvcreate --dataalignment 1m /dev/mapper/arch_lvm
        vgcreate $VOL_GROUP /dev/mapper/arch_lvm
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    else
        pvcreate --dataalignment 1m $OS_DRIVE
        vgcreate $VOL_GROUP $OS_DRIVE
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    fi

    # Prepare/bind EFI
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up EFI/Boot mount points"
    mkdir -p /mnt/efi
    mount $EFI_DRIVE /mnt/efi
    BOOT_PATH=/efi/installs/$HOSTNAME
    mkdir -p /mnt$BOOT_PATH
    mkdir -p /mnt/boot
    mount -o bind /mnt$BOOT_PATH /mnt/boot

    # Generate FS Table (fstab)
    echo -e " ${GREEN}>>${NO_COLOUR} Generating filesystem table (fstab)"
    mkdir -p /mnt/etc
    genfstab -U /mnt >>/mnt/etc/fstab
    sed -i "s|/mnt||" /mnt/etc/fstab
    echo -e " ${GREEN}>>${NO_COLOUR} Generated filesystem table (fstab):"
    cat /mnt/etc/fstab

    # Install base packages
    echo -e " ${GREEN}>>${NO_COLOUR} Install Arch base packages"
    timedatectl set-ntp true
    sed -i '6i Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    pacstrap /mnt base linux linux-firmware lvm2 vim

    # Edit /etc/mkinitcpio.conf (different requirements if drive was encrypted)
    if [ ! -z $ENCRYPT_DRIVE ]; then
        INIT_HOOKS="HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)"
    else
        INIT_HOOKS="HOOKS=(base udev autodetect modconf block lvm2 filesystems fsck)"
    fi
    sed -i "s|^HOOKS=.*|$INIT_HOOKS|" /mnt/etc/mkinitcpio.conf

    echo -e " ${GREEN}>>${NO_COLOUR} Entering root (chroot)"
    arch-chroot /mnt <<-EOF
        set -o errexit
        echo -e "${GREEN}>>${NO_COLOUR} Setting to hardware clock"
        hwclock --systohc
        echo -e "${GREEN}>>${NO_COLOUR} Setting up local hostname"
        echo "$HOSTNAME" >> /etc/hostname
        echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
        echo "::1 $HOSTNAME" >> /etc/hosts
        echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts
        echo -e "${GREEN}>>${NO_COLOUR} Setting up locale"
        sed -i "s|#\($_LOCALE.*\)\$|\1|" /etc/locale.gen
        locale-gen
        echo "LANG=$_LOCALE" >> /etc/locale.conf
        echo -e "${GREEN}>>${NO_COLOUR} Setting up timezone"
        ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        # Install microcode updates
        echo -e "${GREEN}>>${NO_COLOUR} Installing appropriate micro-code"
        cat /proc/cpuinfo | grep -q GenuineIntel && pacman -S --noconfirm intel-ucode 
        cat /proc/cpuinfo | grep -q AuthenticAMD && pacman -S --noconfirm amd-ucode
        # Rebuild boot images
        echo -e "${GREEN}>>${NO_COLOUR} Rebuilding boot images (mkinitcpio)"
        mkinitcpio -p linux
        echo -e "${GREEN}>>${NO_COLOUR} Setting the root user password"
        echo 'root:$ROOT_PASSWORD' | chpasswd
EOF

    # Loader Conf
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up systemd-boot loader entry (loader.conf)"
    echo "default $HOSTNAME" >/mnt/efi/loader/loader.conf
    echo "timeout 5" >>/mnt/efi/loader/loader.conf
    echo "editor 0" >>/mnt/efi/loader/loader.conf
    # Arch Loader Entry Conf
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up systemd-boot ($HOSTNAME.conf)"
    echo "title Arch Linux - $HOSTNAME" >/mnt/efi/loader/entries/$HOSTNAME.conf
    echo "linux $BOOT_PATH/vmlinuz-linux" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    cat /proc/cpuinfo | grep -q GenuineIntel && echo "initrd $BOOT_PATH/intel-ucode.img" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    cat /proc/cpuinfo | grep -q AuthenticAMD && echo "initrd $BOOT_PATH/amd-ucode.img" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    echo "initrd $BOOT_PATH/initramfs-linux.img" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    UUID=$(blkid $OS_DRIVE | cut -d'"' -f2)
    if [ ! -z $ENCRYPT_DRIVE ]; then
        echo "options cryptdevice=UUID=$UUID:volume root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    else
        echo "options root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/efi/loader/entries/$HOSTNAME.conf
    fi
    sed -i "s|/efi||" /mnt/efi/loader/entries/$HOSTNAME.conf

    if [ "$INSTALLNM" == 1 ]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Installing NetworkManager"
        arch-chroot /mnt <<-EOF
        pacman -S --noconfirm networkmanager
        systemctl enable NetworkManager
EOF
    fi

    if [ "$INSTALLBT" == 1 ]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Installing bluetooth"
        arch-chroot /mnt <<-EOF
        pacman -S --noconfirm bluez bluez-utils pulseaudio-alsa pulseaudio-bluetooth
        systemctl enable bluetooth
EOF
    fi

    if [[ PARALLEL_PACMAN -eq 1 ]]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Changing pacman to use parallel downloads"
        sed -i 's/#ParallelDownloads/ParallelDownloads/g' /mnt/etc/pacman.conf
    fi

    echo -e " ${GREEN}>>${NO_COLOUR} Setup complete!"
}

format_drive
