#!/bin/env bash

# Exit on any error
set -o errexit

# Colours
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

# Functions
print_usage() {
    echo "Usage: "
    echo "   arch-base.sh format <device>"
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
OS_DRIVE=
SWAP_DRIVE=

# Command-Line Parsing
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
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
if [ -z "$OS_DRIVE" ]; then
    print_usage
    exit 0
fi

# Support nvme drives
OS_DRIVE_="$OS_DRIVE" # Partition Prefix
if [[ "$2" =~ ^/dev/nvme ]]; then OS_DRIVE_="${OS_DRIVE}p"; fi

format_drive() {
    echo " >> Formatting $OS_DRIVE"
    gdisk -l "$OS_DRIVE"
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
    echo -n -e " ${CYAN}>>${NO_COLOUR} Set hostname: "
    read _HOSTNAME
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
    printf " ${CYAN}>>${NO_COLOUR} Enter the size of the created LVM partition (+G/-G/0, default: 0): "
    read LVM_PARTITION_SIZE
    LVM_PARTITION_SIZE="${LVM_PARTITION_SIZE:-0}"

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
    echo -e " ${GREEN}>>${NO_COLOUR} Formatting drive"
    if [[ $SHRED_ITERATIONS -gt 0 ]]; then
        shred -v -n$SHRED_ITERATIONS "$OS_DRIVE"
    fi
    sgdisk -o "$OS_DRIVE"
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" "$OS_DRIVE"
    sgdisk -n 2:0:$LVM_PARTITION_SIZE -t 2:8e00 -c 2:"$VOL_GROUP LVM" "$OS_DRIVE"
    sgdisk -p "$OS_DRIVE"

    # Encrypt LVM
    if [ ! -z $ENCRYPT_DRIVE ]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Encrypting main partition"
        cryptsetup luksFormat --type luks2 "$OS_DRIVE_"2 -q <<<"$DISK_PASSWORD"
        cryptsetup open "$OS_DRIVE_"2 arch_lvm -q <<<"$DISK_PASSWORD"
        pvcreate --dataalignment 1m /dev/mapper/arch_lvm
        vgcreate $VOL_GROUP /dev/mapper/arch_lvm
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    else
        pvcreate --dataalignment 1m "$OS_DRIVE_"2
        vgcreate $VOL_GROUP "$OS_DRIVE_"2
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    fi

    # Prepare/bind EFI
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up ESP/EFI/Boot partition"
    mkfs.fat -F32 "$OS_DRIVE_"1
    mkdir /mnt/efi
    mount "$OS_DRIVE_"1 /mnt/efi

    # Install bootloader
    bootctl --path=/mnt/efi install

    # Bind OS boot path to the appropriate EFI directory
    BOOT_PATH=/efi/installs/$_HOSTNAME
    mkdir -p /mnt$BOOT_PATH
    mkdir /mnt/boot
    mount -o bind /mnt$BOOT_PATH /mnt/boot

    # Mount Swap partition
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up Swap partition"
    if [ ! -z "$SWAP_DRIVE" ]; then
        swapon $SWAP_DRIVE
    fi

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
        echo "$_HOSTNAME" >> /etc/hostname
        echo "127.0.0.1 $_HOSTNAME" >> /etc/hosts
        echo "::1 $_HOSTNAME" >> /etc/hosts
        echo "127.0.1.1 $_HOSTNAME.localdomain $_HOSTNAME" >> /etc/hosts
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
    echo "default $_HOSTNAME" >/mnt/efi/loader/loader.conf
    echo "timeout 5" >>/mnt/efi/loader/loader.conf
    echo "editor 0" >>/mnt/efi/loader/loader.conf
    # Arch Loader Entry Conf
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up systemd-boot ($_HOSTNAME.conf)"
    echo "title Arch Linux" >/mnt/efi/loader/entries/$_HOSTNAME.conf
    echo "linux $BOOT_PATH/vmlinuz-linux" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    cat /proc/cpuinfo | grep -q GenuineIntel && echo "initrd $BOOT_PATH/intel-ucode.img" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    cat /proc/cpuinfo | grep -q AuthenticAMD && echo "initrd $BOOT_PATH/amd-ucode.img" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    echo "initrd $BOOT_PATH/initramfs-linux.img" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    UUID=$(blkid "$OS_DRIVE_"2 | cut -d'"' -f2)
    if [ ! -z $ENCRYPT_DRIVE ]; then
        echo "options cryptdevice=UUID=$UUID:volume root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    else
        echo "options root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/efi/loader/entries/$_HOSTNAME.conf
    fi
    sed -i "s|/efi||" /mnt/efi/loader/entries/$_HOSTNAME.conf

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
