#!/usr/bin/bash

function makeSwapFile() {
  cd /mnt/.swap

  truncate -s 0 ./swapfile
  chattr +C ./swapfile
  btrfs property set ./swapfile compression none
  dd if=/dev/zero of=./swapfile bs=1M count="$SWAP_SIZE_IN_MB" status=progress

  chmod 600 ./swapfile
  mkswap ./swapfile
  swapon ./swapfile
}

