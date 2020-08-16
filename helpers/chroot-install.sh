#!/usr/bin/bash

set -uexo pipefail

cd /archer/installer

source "./helpers/variables.sh"
source "./helpers/packages.sh"
source "./helpers/users.sh"

function copyConfs() {
    cp /archer/conf/hosts /etc/hosts
    cp /archer/installer/conf/mkinitcpio.conf /etc/mkinitcpio.conf
    cp /archer/installer/boot/loader.conf /boot/loader/loader.conf
    cp /archer/installer/boot/arch.conf /boot/loader/entries/arch.conf
}

copyConfs

timedatectl set-timezone "Europe/London"
timedatectl set-ntp true
hwclock --systohc

sed -i "s/#en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
localectl set-locale LANG=en_GB.UTF-8
locale-gen

echo "$HOSTNAME" > /etc/hostname
sed -i "s/_HOSTNAME/$HOSTNAME/g" /etc/hosts
sed -i "s/#Color/Color/g" /etc/pacman.conf

bootctl install

users
corePackages
developerTooling
installYay
awesomeShell

systemctl enable gdm
systemctl enable NetworkManager

# TODO: Customisation stuff (dot files)

exit
