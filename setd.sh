#!/bin/bash

do_update_system() {
  clear
  sudo pacman -Syu --noconfirm
}

do_install() {
  clear
  sudo pacman -S --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
}

do_update_system &&
do_install
