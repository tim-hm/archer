#! /usr/bin/bash

# ref: https://wiki.archlinux.org/index.php/USB_flash_installation_medium#In_GNU/Linux_2

set -uexo pipefail

CUSTOMIZATION=""
ARCH_ISO="http://mirrors.evowise.com/archlinux/iso/2020.08.01/archlinux-2020.08.01-x86_64.iso"
LABEL_ARCH="ARCH_202008"
LABEL_DATA="DATA"
#DEVICE=""
PARTITION_ARCH="${DEVICE}1"
PARTITION_ARCHINS="${DEVICE}2"
INSTALLER_ISO="/tmp/arch.iso"
USB="/mnt/usb"
ISO="/mnt/iso"
DATA="/mnt/data"

if [ "$EUID" != "0" ]; then
    echo "Run with root privileges"
fi

# curl -o $ISO $ARCH_ISO

# format usb
sgdisk --zap-all "$DEVICE"
sgdisk \
    --new=1:0:+700MiB --typecode=1:ef00 --change-name=1:"$LABEL_ARCH" \
    --new=2:0:0 --typecode=2:8300 --change-name=2:"$LABEL_DATA" \
    "$DEVICE"

mkdir -p /mnt/{usb,iso,data}
mount -o loop "$INSTALLER_ISO" "$ISO"

mkfs.fat -F32 -n "$LABEL_ARCH" "$PARTITION_ARCH"
mount "$PARTITION_ARCH" "$USB"
cp -a "$ISO"/* "$USB"

mkfs.ext4 "$PARTITION_ARCHINS" # TODO: use luks + crypt so we can put keys in there
mount "$PARTITION_ARCHINS" "$DATA"
mkdir "$DATA"/installer
git clone --single-branch wip https://github.com/tim-hm/archer.git "$USB/installer"

sync
umount "$ISO"
umount "$USB"
umount "$DATA"

exit