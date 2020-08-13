#!/usr/bin/bash

function partitionDrive() {
  sgdisk --zap-all $DRIVE
  sgdisk --clear \
    --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0       --typecode=2:8300 --change-name=2:system \
    $DRIVE

  mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
  mkfs.btrfs -f --label system /dev/disk/by-partlabel/system

  mount -t btrfs LABEL=system /mnt
  btrfs subvolume create /mnt/root
  btrfs subvolume create /mnt/home
  btrfs subvolume create /mnt/snapshots
  btrfs subvolume create /mnt/swap
  umount -R /mnt

  OPTIONS=defaults,x-mount.mkdir,compress=lzo,ssd,noatime,nodiratime
  mount -o subvol=root,$OPTIONS LABEL=system /mnt
  mount -o subvol=home,$OPTIONS LABEL=system /mnt/home
  mount -o subvol=snapshots,$OPTIONS LABEL=system /mnt/.snapshots
  mount -o subvol=swap,$OPTIONS LABEL=system /mnt/.swap

  mkdir /mnt/boot
  mount LABEL=EFI /mnt/boot
}
