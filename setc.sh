#!/bin/bash

TARGET_USER="jontas"

INSTALL_NEEDED="needed.txt"
INSTALL_OPTIONAL="optional.txt"
USER_VARS="user_vars"

CHAOTIC_REPO_NAME="chaotic-aur"
CHAOTIC_REPO_KEY="3056513887B78AEB"
CHAOTIC_REPO_URL="https://cdn-mirror.chaotic.cx/chaotic-aur/"


print_color() {
  local color=$1
  local message=$2
  printf "\033[1;${color}m$message\033[0m\n"
}

add_chaotic_aur() {
  if grep -q "^\[$CHAOTIC_REPO_NAME\]" /etc/pacman.conf; then
    print_color "33" "$CHAOTIC_REPO_NAME is already in /etc/pacman.conf"
  else
    if pacman-key --recv-key "$CHAOTIC_REPO_KEY" --keyserver keyserver.ubuntu.com && \
       pacman-key --lsign-key "$CHAOTIC_REPO_KEY"; then
      if pacman -U "$CHAOTIC_REPO_URL/chaotic-keyring.pkg.tar.zst" --noconfirm && \
         pacman -U "$CHAOTIC_REPO_URL/chaotic-mirrorlist.pkg.tar.zst" --noconfirm; then
        echo "
[$CHAOTIC_REPO_NAME]
Include = /etc/pacman.d/chaotic-mirrorlist" | tee -a /etc/pacman.conf
        print_color "32" "$CHAOTIC_REPO_NAME has been added to /etc/pacman.conf"
      else
        print_color "31" "Failed to install keyring or mirrorlist"
      fi
    else
      print_color "31" "Failed to retrieve or sign the PGP key"
    fi
  fi
}

do_update_system() {
  clear
  print_color "33" "Chaotic AUR enabled.\nSync and update"
  sudo pacman -Syu --noconfirm
}

setup_system_root() {
  echo "jontas ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/jontas"
}


  add_chaotic_aur &&
  do_update_system &&
  setup_system_user

