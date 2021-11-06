#!/bin/env bash
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

DRIVE="$2"

# Exit on any error
set -o errexit

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

format_drive() {
    echo " >> Formatting $DRIVE"
    gdisk -l "$DRIVE"
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
        shred -v -n$SHRED_ITERATIONS "$DRIVE"
    fi
    sgdisk -o "$DRIVE"
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" "$DRIVE"
    sgdisk -n 2:0:$LVM_PARTITION_SIZE -t 2:8e00 -c 2:"$VOL_GROUP LVM" "$DRIVE"
    sgdisk -p "$DRIVE"

    # Encrypt LVM
    if [ ! -z $ENCRYPT_DRIVE ]; then
        echo -e " ${GREEN}>>${NO_COLOUR} Encrypting main partition"
        cryptsetup luksFormat --type luks2 "$DRIVE_"2 -q <<<"$DISK_PASSWORD"
        cryptsetup open "$DRIVE_"2 arch_lvm -q <<<"$DISK_PASSWORD"
        pvcreate --dataalignment 1m /dev/mapper/arch_lvm
        vgcreate $VOL_GROUP /dev/mapper/arch_lvm
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    else
        pvcreate --dataalignment 1m "$DRIVE_"2
        vgcreate $VOL_GROUP "$DRIVE_"2
        lvcreate -l $ROOT_SIZE $VOL_GROUP -n root
        mkfs.ext4 /dev/$VOL_GROUP/root
        mount /dev/$VOL_GROUP/root /mnt
    fi

    # Prepare EFI
    echo -e " ${GREEN}>>${NO_COLOUR} Installing OS"
    mkfs.fat -F32 "$DRIVE_"1
    mkdir /mnt/boot
    mount "$DRIVE_"1 /mnt/boot

    # Prepare bootloader
    echo -e " ${GREEN}>>${NO_COLOUR} Preparing bootloader"
    sed -i '6i Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    timedatectl set-ntp true
    pacstrap /mnt base linux linux-firmware lvm2 vim
    genfstab -U /mnt >>/mnt/etc/fstab
    # Edit /etc/mkinitcpio.conf
    if [ -z $ENCRYPT_DRIVE ]; then
        INIT_HOOKS="HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)"
    else
        INIT_HOOKS="HOOKS=(base udev autodetect modconf block lvm2 filesystems fsck)"
    fi
    sed -i "s|^HOOKS=.*|$INIT_HOOKS|" /mnt/etc/mkinitcpio.conf

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
        # Install bootloaders
        echo -e "${GREEN}>>${NO_COLOUR} Installing bootloader (mkinitcpio/bootctl)"
        mkinitcpio -p linux
        bootctl install
        echo -e "${GREEN}>>${NO_COLOUR} Setting the root user password"
        echo root:$ROOT_PASSWORD | chpasswd
EOF

    # Loader Conf
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up systemd-boot (loader.conf)"
    echo "default arch" >/mnt/boot/loader/loader.conf
    echo "timeout 5" >>/mnt/boot/loader/loader.conf
    echo "editor 0" >>/mnt/boot/loader/loader.conf
    # Arch Loader Entry Conf
    echo -e " ${GREEN}>>${NO_COLOUR} Setting up systemd-boot (arch.conf)"
    echo "title Arch Linux" >/mnt/boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux" >>/mnt/boot/loader/entries/arch.conf
    cat /proc/cpuinfo | grep -q GenuineIntel && echo "initrd /intel-ucode.img" >>/mnt/boot/loader/entries/arch.conf
    cat /proc/cpuinfo | grep -q AuthenticAMD && echo "initrd /amd-ucode.img" >>/mnt/boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux.img" >>/mnt/boot/loader/entries/arch.conf
    UUID=$(blkid "$DRIVE_"2 | cut -d'"' -f2)
    if [ -z $ENCRYPT_DRIVE ]; then
        echo "options cryptdevice=UUID=$UUID:volume root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/boot/loader/entries/arch.conf
    else
        echo "options root=/dev/mapper/$VOL_GROUP-root quiet rw" >>/mnt/boot/loader/entries/arch.conf
    fi

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
        sed -i 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf
    fi

    echo -e " ${GREEN}>>${NO_COLOUR} Setup complete!"
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
