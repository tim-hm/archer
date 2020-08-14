#!/usr/bin/bash

function finish() {
    rm -rf /mnt/archer

    swapoff /mnt/.swap/swapfile
    sleep 1

    umount -R /mnt
    umount "$INSTALLER"

    #reboot
}