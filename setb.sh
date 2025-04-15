#!/bin/bash

check_yay() {
  if ! command -v yay >/dev/null 2>&1; then 
    git clone https://aur.archlinux.org/yay.git /tmp/yay &&
    cd /tmp/yay &&
    makepkg -si --noconfirm &&
    cd ~
  fi
}

check_yay





