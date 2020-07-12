#!/bin/bash

DRIVE="$2"
SWAP_SIZE="${SWAP_SIZE-16G}"
VOL_GROUP="${VOL_GROUP-STec}"
SHRED_ITERATIONS="${SHRED_ITERATIONS-1}"

# Exit on any error
set -o errexit

print_usage() {
    echo "Usage: "
    echo "   arch-install.sh format <device>"
}

confirm() {
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

format_drive() {
    echo " >> Formatting $DRIVE"
    gdisk -l "$DRIVE"
    echo -n ' >> Are you sure? Type "YES" to confirm: '
    _CONFIRM=""
    read _CONFIRM
    if [ "$_CONFIRM" != "YES" ]; then exit 1; fi

    confirm " >> Shred the drive data? [y/N]" && export SHRED_DRIVE=1

    # Collect Setup params
    DISK_PASSWORD=""
    while [ -z "$DISK_PASSWORD" ]; do
        echo -n " >> Set DISK Password:"
        read -s -r TEMP_PWORD
        echo
        echo -n " >> Confirm DISK Password:"
        read -s -r TEMP_PWORD_2
        echo
        if [ "$TEMP_PWORD" == "$TEMP_PWORD_2" ]; then DISK_PASSWORD="$TEMP_PWORD"; fi
    done
    echo -n " >> Set hostname: "
    read _HOSTNAME
    echo -n " >> Set locale [en_US.UTF-8]: "
    read _LOCALE
    _LOCALE="${_LOCALE:-en_US.UTF-8}"
    echo -n " >> Set timezone [America/Toronto]: "
    read TIMEZONE
    TIMEZONE="${TIMEZONE:-America/Toronto}"
    echo " >>>> Running..."

    # Wipe and format drive
    if [ SHRED_DRIVE == 1 ]; then
        shred -v -n$SHRED_ITERATIONS "$DRIVE"
    fi
    sgdisk -o "$DRIVE"
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" "$DRIVE"
    sgdisk -n 2:0:0 -t 2:8e00 -c 2:"$VOL_GROUP LVM" "$DRIVE"
    sgdisk -p "$DRIVE"

    # Encrypt LVM
    cryptsetup luksFormat --type luks2 "$DRIVE_"2 -q <<<"$DISK_PASSWORD"
    cryptsetup open "$DRIVE_"2 arch_lvm -q <<<"$DISK_PASSWORD"
    pvcreate --dataalignment 1m /dev/mapper/arch_lvm
    vgcreate $VOL_GROUP /dev/mapper/arch_lvm
    lvcreate -l 100%FREE $VOL_GROUP -n root
    mkfs.ext4 /dev/$VOL_GROUP/root
    mount /dev/$VOL_GROUP/root /mnt

    # Prepare EFI
    mkfs.fat -F32 "$DRIVE_"1
    mkdir /mnt/boot
    mount "$DRIVE_"1 /mnt/boot

    # Prepare bootloader
    sed -i '6i Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    timedatectl set-ntp true
    pacstrap /mnt base linux linux-firmware lvm2 vim
    genfstab -U /mnt >>/mnt/etc/fstab
    # Edit /etc/mkinitcpio.conf
    INIT_HOOKS="HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)"
    sed -i "s|^HOOKS=.*|$INIT_HOOKS|" /mnt/etc/mkinitcpio.conf

    arch-chroot /mnt <<-EOF
        set -o errexit
        hwclock --systohc
        echo "$_HOSTNAME" >> /etc/hostname
        echo "127.0.0.1 $_HOSTNAME" >> /etc/hosts
        echo "::1 $_HOSTNAME" >> /etc/hosts
        echo "127.0.1.1 $_HOSTNAME.localdomain $_HOSTNAME" >> /etc/hosts
        sed -i "s|#\($_LOCALE.*\)\$|\1|" /etc/locale.gen
        locale-gen
        echo "LANG=$_LOCALE" >> /etc/locale.conf
        ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        # Install microcode updates
        cat /proc/cpuinfo | grep -q GenuineIntel && pacman -S --noconfirm intel-ucode 
        cat /proc/cpuinfo | grep -q AuthenticAMD && pacman -S --noconfirm amd-ucode
        # Install bootloaders
        mkinitcpio -p linux
        bootctl install
EOF

    # Loader Conf
    echo "default arch" >/mnt/boot/loader/loader.conf
    echo "timeout 5" >>/mnt/boot/loader/loader.conf
    echo "editor 0" >>/mnt/boot/loader/loader.conf
    # Arch Loader Entry Conf
    echo "title Arch Linux" >/mnt/boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux" >>/mnt/boot/loader/entries/arch.conf
    cat /proc/cpuinfo | grep -q GenuineIntel && echo "initrd /intel-ucode.img" >>/mnt/boot/loader/entries/arch.conf
    cat /proc/cpuinfo | grep -q AuthenticAMD && echo "initrd /amd-ucode.img" >>/mnt/boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux.img" >>/mnt/boot/loader/entries/arch.conf
    UUID=$(blkid "$DRIVE_"2 | cut -d'"' -f2)
    echo "options cryptdevice=UUID=$UUID:volume root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/boot/loader/entries/arch.conf

    echo " >>>> Setup complete!"
    echo " >> Be sure to set root password!"
}

# Support nvme drives
DRIVE_="$DRIVE" # Partition Prefix
if [[ "$2" =~ ^/dev/nvme ]]; then DRIVE_="${DRIVE}p"; fi

##
if [ "$1" == "format" ]; then
    format_drive
else
    print_usage
    exit 1
fi
