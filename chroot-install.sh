#!/usr/bin/bash

set -uexo pipefail

cd /archer/installer

source "./helpers/variables.sh"
source "./helpers/packages.sh"
source "./helpers/users.sh"

timedatectl set-timezone "Europe/London"
timedatectl set-ntp true
hwclock --systohc

sed -i "s/#en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
localectl set-locale LANG=en_GB.UTF-8
locale-gen

hostnamectl set-hostname "$HOSTNAME"
sed -i "s/_HOSTNAME/$HOSTNAME/g" /etc/hosts

cp "/archer/installer/conf/mkinitcpio.conf" /etc/mkinitcpio.conf

bootctl install
cp "/archer/installer/boot/loader.conf" /boot/loader/loader.conf
cp "/archer/installer/boot/arch.conf" /boot/loader/entries/arch.conf

users
corePackages
developerTooling
installYay
awesomeShell

systemctl enable gdm
systemctl enable NetworkManager

# TODO: Copy over dotfiles

# TODO: Setup root user

exit

