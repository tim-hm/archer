#! /usr/bin/bash

set -euxo pipefail

cd "/archer/installer"

source "./helpers/check.sh"
source "./helpers/variables.sh"
source "./helpers/wifi.sh"
source "./helpers/partioning.sh"
source "./helpers/swap.sh"
source "./helpers/packages.sh"

timedatectl set-ntp true

partitionDrive
makeSwapFile

pacstrap /mnt base base-devel zsh 
genfstab -L -p /mnt >> /mnt/etc/fstab
mkdir -p /mnt/archer
cp -r "$INSTALLER" /mnt/archer

arch-chroot /mnt /bin/bash -c "/archer/installer/chroot-install.sh"

swapoff /mnt/.swap/swapfile

sleep 1
umount -R /mnt
umount "$INSTALLER"

#reboot
