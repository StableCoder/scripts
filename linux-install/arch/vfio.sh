#!/usr/bin/env sh

# Copyright (C) 2022 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

RED='\033[0;31m'
DEFAULT='\033[0m'

# Disabled ATM, as this seems the screw up libvirt right now, but is required for using
# host-passthrough CPU type for Windows
#echo 'options kvm ignore_msrs=1' | sudo tee -a /etc/modprobe.d/kvm.conf

# This script sets all non-boot GPUs to load the vfio module
cat >/usr/local/bin/vfio-pci-override.sh <<EOF
#!/bin/sh

for i in /sys/bus/pci/devices/*/boot_vga; do
    if [ \$(cat "\$i") -eq 0 ]; then
        GPU="\${i%/boot_vga}"
        AUDIO="\$(echo "\$GPU" | sed -e "s/0$/1/")"
        echo "vfio-pci" > "\$GPU/driver_override"
        if [ -d "\$AUDIO" ]; then
            echo "vfio-pci" > "\$AUDIO/driver_override"
        fi
    fi
done

modprobe -i vfio-pci
EOF

chmod +x /usr/local/bin/vfio-pci-override.sh
echo 'install vfio-pci /usr/local/bin/vfio-pci-override.sh' >/etc/modprobe.d/vfio.conf

echo -e " ${RED}>>${DEFAULT}" 'Add "amd_iommu=on" to kernel parameters on the /boot/loader/entries/arch.conf file'
echo -e " ${RED}>>${DEFAULT}"
echo -e " ${RED}>>${DEFAULT}" 'Add these to the file: /etc/mkinitcpio.conf'
echo -e " ${RED}>>${DEFAULT}" 'MODULES=(... vfio_pci vfio vfio_iommu_type1 vfio_virqfd ...)'
echo -e " ${RED}>>${DEFAULT}" 'HOOKS=(... modconf ...)'
echo -e " ${RED}>>${DEFAULT}" 'FILES=(... /usr/local/bin/vfio-pci-override.sh ...)'
echo -e " ${RED}>>${DEFAULT}"
echo -e " ${RED}>>${DEFAULT}" 'Then rebuild the kernel with "mkinitcpio -p linux"'
