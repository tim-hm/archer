#! /usr/bin/bash

set -euxo pipefail

# SSID=""
# WIFI_PASS=""
# DRIVE=""  # /dev/sda
# HOSTNAME=""
# USER=""
YAY_AUR="https://aur.archlinux.org/yay-bin.git"

if !ls /sys/firmware/efi/efivars >/dev/null; then
  echo "Did not find expected EFI variables"
  exit 1
fi

mkdir /installer
cp *.conf /installer

iwctl --passphrase $WIFI_PASS station wlan0 connect $SSID
if ! ping google.com -c 1 -W 1000; then 
  echo "Failed to connect to the internet"
  exit 1
fi

timedatectl set-ntp true

sgdisk --zap-all $DRIVE
sgdisk --clear \
  --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
  --new=2:0:0       --typecode=2:8300 --change-name=2:system \
  $DRIVE

OPTIONS=defaults,x-mount.mkdir,compress=lzo,ssd,noatime,nodiratime

mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mkfs.btrfs --label system /dev/disk/by-partlabel/system

mount -t btrfs LABEL=system /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/snapshots
btrfs subvolume create /mnt/swap
umount -R /mnt

mount -o subvol=root,$OPTIONS LABEL=system /mnt
mount -o subvol=home,$OPTIONS LABEL=home /mnt/home
mount -o subvol=snapshots,$OPTIONS LABEL=home /mnt/.snapshots
mount -o subvol=swap,$OPTIONS LABEL=home /mnt/.swap

mkdir /mnt/boot
mount LABEL=EFI /mnt/boot

cd /mnt/.swap
truncate -s 0 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none
dd if=/dev/zero of=./swapfile bs=1M count=12000 status=progress
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile

pacstrap /mnt base linux linux-firmware zsh
genfstab -L -p /mnt >> /mnt/etc/fstab

cp /installer/* /mnt/tmp
arch-chroot /mnt

timedatectl set-timezone Europe/London
timedatectl set-ntp true
hwclock --systohc

sed -i "s/#en_GB.UTF-8/en_GB.UTF-8/g" locale.gen
localctl set-locale LANG=en_GB.UTF-8
locale-gen

hostnamectl set-hostname $HOSTNAM

sed -i "s/_HOSTNAME/$HOSTNAME/g" /etc/hosts

useradd -m -s /usr/bin/zsh $USER
usermod -aG wheel $USER
usermod -aG input $USER

passwd tim
passwd -l root

sed -i "s/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers
echo "Defaults pwfeedback" >> /etc/sudoers

cp /tmp/mkinitcpio.conf /etc/mkinitcpio.conf
cp /tmp/loader.conf /boot/loader/loader.conf
cp /tmp/arch.conf /boot/loader/entries/arch.conf
bootctl install

pacman -S --noconfirm gnome gnome-extra base-devel intel-ucode git tilix \
  firefox btrfs-progs \
  zsh-theme-powerlevel10k zsh-syntax-highlighting zsh-autosuggestions

systemctl enable gdm
systemctl enable NetworkManager

cd /tmp
git clone $YAY_AUR
cd yay-bin
makepgk -sri --noconfirm

yay --no-confirm libinput-gestures

su tim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# TODO: Copy over dotfiles

# TODO: Setup root user

exit
umount -R /mnt
reboot