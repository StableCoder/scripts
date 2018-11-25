#!/bin/bash

DRIVE="$2"
SWAP_SIZE="${SWAP_SIZE-16G}"
VOL_GROUP="${VOL_GROUP-STec}"
SHRED_ITERATIONS="${SHRED_ITERATIONS-1}"

# Exit on any error
set -o errexit

print_usage () {
    echo "Usage: "
    echo "   arch-install.sh format <device>"
    echo "   arch-install.sh mount <device>"
}

confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

mount_drive () {
    echo " >> Mounting $DRIVE"
    cryptsetup open "$DRIVE_"4 cryptlvm
    sleep 1
    mount /dev/$VOL_GROUP/root /mnt
    swapon /dev/$VOL_GROUP/swap
    cryptsetup open "$DRIVE_"3 cryptboot --key-file /mnt/crypto_keyfile.bin
    mount /dev/mapper/cryptboot /mnt/boot
    mount "$DRIVE_"2 /mnt/efi
}

format_drive () {
    echo " >> Formatting $DRIVE"
    gdisk -l "$DRIVE"
    echo -n ' >> Are you sure? Type "YES" to confirm: '
    _CONFIRM=""
    read _CONFIRM
    if [ "$_CONFIRM" != "YES" ]; then exit 1; fi

    confirm " >> Shred the drive data? [y/N]" && export SHRED_DRIVE=1

    # Collect Setup params
    PASSWORD=""
    while [ -z "$PASSWORD" ]; do
        echo -n " >> Set DISK Password:"
        read -s -r TEMP_PWORD; echo
        echo -n " >> Confirm DISK Password:"
        read -s -r TEMP_PWORD_2; echo
        if [ "$TEMP_PWORD" == "$TEMP_PWORD_2" ]; then PASSWORD="$TEMP_PWORD"; fi
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
    sgdisk -n 1:0:+1M -t 1:ef02 -c 1:"BIOS Boot Partition" "$DRIVE"
    sgdisk -n 2:0:+550M -t 2:ef00 -c 2:"EFI System Partition" "$DRIVE"
    sgdisk -n 3:0:+200M -t 3:8300 -c 3:"Boot partition" "$DRIVE"
    sgdisk -n 4:0:0 -t 4:8e00 -c 4:"$VOL_GROUP LVM" "$DRIVE"
    sgdisk -p "$DRIVE"

    # Prepare main partition
    dd bs=512 count=8 if=/dev/urandom of=/tmp/crypto_keyfile.bin
    cryptsetup luksFormat --type luks2 "$DRIVE_"4 -q --key-file /tmp/crypto_keyfile.bin
    cryptsetup luksAddKey "$DRIVE_"4 -q --key-file /tmp/crypto_keyfile.bin <<< "$PASSWORD"
    cryptsetup open "$DRIVE_"4 cryptlvm --key-file /tmp/crypto_keyfile.bin
    pvcreate /dev/mapper/cryptlvm
    vgcreate $VOL_GROUP /dev/mapper/cryptlvm
    lvcreate -L $SWAP_SIZE $VOL_GROUP -n swap
    lvcreate -l 100%FREE $VOL_GROUP -n root
    mkfs.ext4 /dev/$VOL_GROUP/root
    mkswap /dev/$VOL_GROUP/swap
    mount /dev/$VOL_GROUP/root /mnt
    swapon /dev/$VOL_GROUP/swap
    mv /tmp/crypto_keyfile.bin /mnt/

    # Prepare boot partition
    chmod 000 /mnt/crypto_keyfile.bin
    cryptsetup luksFormat "$DRIVE_"3 -q --key-file /mnt/crypto_keyfile.bin
    cryptsetup luksAddKey "$DRIVE_"3 -q --key-file /mnt/crypto_keyfile.bin <<< "$PASSWORD"
    cryptsetup open "$DRIVE_"3 cryptboot --key-file /mnt/crypto_keyfile.bin
    mkfs.ext4 /dev/mapper/cryptboot
    mkdir /mnt/boot
    mount /dev/mapper/cryptboot /mnt/boot

    # Preare efi partition
    mkfs.fat -F32 "$DRIVE_"2
    mkdir /mnt/efi
    mount "$DRIVE_"2 /mnt/efi

    # Prepare bootloader
    sed -i '6i Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    timedatectl set-ntp true
    pacstrap /mnt base grub efibootmgr
    genfstab -U /mnt >> /mnt/etc/fstab
    # Edit /etc/mkinitcpio.conf
    INIT_HOOKS="HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 resume filesystems fsck)"
    INIT_FILE="FILES=(/crypto_keyfile.bin)"
    sed -i "s|^HOOKS=.*|$INIT_HOOKS|" /mnt/etc/mkinitcpio.conf
    sed -i "s|^FILES=.*|$INIT_FILE|" /mnt/etc/mkinitcpio.conf
    # Edit /etc/default/grub
    LVM_BLKID=`blkid "$DRIVE_"4 | sed -n 's/.* UUID=\"\([^\"]*\)\".*/\1/p'`
    GRUB_CMD="GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$LVM_BLKID:cryptlvm resume=/dev/$VOL_GROUP/swap\""
    GRUB_CRYPTO="GRUB_ENABLE_CRYPTODISK=y"
    sed -i "s|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|" /mnt/etc/default/grub
    sed -i "s|^GRUB_CMDLINE_LINUX=.*|$GRUB_CMD|" /mnt/etc/default/grub
    sed -i "s|^#GRUB_ENABLE_CRYPTODISK=.*|$GRUB_CRYPTO|" /mnt/etc/default/grub
    echo "cryptboot ${DRIVE_}3 /crypto_keyfile.bin luks" >> /mnt/etc/crypttab

    arch-chroot /mnt <<- EOF
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
        grub-mkconfig -o /boot/grub/grub.cfg
        grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ARCH --recheck
        grub-install --target=i386-pc --recheck "$DRIVE"
        mkinitcpio -p linux
        chmod 600 /boot/initramfs-linux*
EOF
    echo " >>>> Setup complete!"
}

# Support nvme drives
DRIVE_="$DRIVE" # Partition Prefix
if [[ "$2" =~ ^/dev/nvme ]]; then DRIVE_="${DRIVE}p"; fi

##
if [ "$1" == "format" ]; then
    format_drive
elif [ "$1" == "mount" ]; then
    mount_drive
else
    print_usage
    exit 1
fi
