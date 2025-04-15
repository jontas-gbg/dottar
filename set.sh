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
  pacman -Syu --noconfirm
}

do_pre_install() {
  print_color "33" "Installing Yay.\n"
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit 1
  makepkg -si --noconfirm
  cd ..
}

do_install_from_list() {
  print_color "33" "\nInstalling apps."
  local file="$1"
  while IFS= read -r app; do
    if [[ -n "$app" && ! "$app" =~ ^[[:space:]]*# ]]; then
      app=$(echo "$app" | xargs)
      if ! pacman -Q "$app" &> /dev/null; then
        if ! yay -S --noconfirm "$app"; then
          echo "Error: $app could not be installed."
        fi
      else
        echo "$app already installed"
      fi
    fi
  done < "$file"
}

setup_system_root() {
  print_color "33" "Konfigurerar sudoers och aktiverar SDDM..."
  sed -n '1p' "$USER_VARS" | tee "/etc/sudoers.d/$TARGET_USER"
  systemctl enable sddm
}

setup_system_user() {
  print_color "33" "Setting up user defined tweaks"
  su - "$TARGET_USER" -c "chsh -s $(which zsh)"
}

main() {
  if [[ $EUID -ne 0 ]]; then
    print_color "31" "\n\nRun install script with sudo.\Terminated"
    exit 1
  fi

  add_chaotic_aur &&
  do_update_system &&
  do_pre_install &&
  do_install_from_list "$INSTALL_NEEDED" &&
  do_install_from_list "$INSTALL_OPTIONAL" &&
  setup_system_root &&
  setup_system_user
}

main "$@"

