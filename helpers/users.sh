#!/usr/bin/bash

function users() {
  echo "hello from users"
  useradd -m -s /usr/bin/zsh "$USERNAME"
  usermod -aG wheel "$USERNAME"
  usermod -aG input "$USERNAME"
  passwd "$USERNAME"

  passwd -l root

  sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers
  echo "Defaults pwfeedback" >> /etc/sudoer
}

