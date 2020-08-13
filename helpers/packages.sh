#! /usr/bin/bash

BASIC=(
    gnome
    gnome-extra
    linux
    linux-firmware
    intel-ucode
    firefox
    btrfs-progs
)

function corePackages() {
  pacman -S --noconfirm "${BASIC[@]}"
}

function enhanceGnome() {
  yay --no-confirm libinput-gestures
}

DEVELOPER=(
    git
    vim
    tilix
    docker
    docker-compose
    typescript
    yarn
    shellcheck
    gradle
    jdk-openjdk
)

function developerTooling() {
  pacman -S --noconfirm "${DEVELOPER[@]}"
}

AWESOME_SHELL=(
    zsh-theme-powerlevel10k
    zsh-syntax-highlighting
    zsh-autosuggestions
)

function awesomeShell() {
    pacman -S --noconfirm "${AWESOME_SHELL[@]}"
    sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo -u "$USERNAME" touch "/home/$USERNAME/.zshrc"
}

function installYay() {
    git clone $YAY_AUR /tmp/yay-bin
    chown -R $USERNAME:$USERNAME /tmp/yay-bin
    cd /tmp/yay-bin
    sudo -u "$USERNAME" makepkg -sri --noconfirm
}

function installFromAur() {
  echo "TODO"
}
