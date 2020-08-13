#! /usr/bin/bash

if ! ls /sys/firmware/efi/efivars > /dev/null; then
  echo "Did not find EFI variables ... did you boot via EFI?"
  exit 1
fi
