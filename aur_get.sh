#!/bin/bash

aurget_one() {
  if ! pacman -Q $1; then
    cd aur_repos
    git clone --depth 1 https://aur.archlinux.org/$1.git
    cd $1
    makepkg -si
    cd /tmp
    rm -rf /tmp/aur_repos/*
    echo "    Success."
  fi
}

aurget() {
  if [ "$EUID" -eq 0 ]; then
    echo "    You shouldn't run this command as root. Aborting."
    return 1
  fi
  cd /tmp
  mkdir -p aur_repos
  while (( $# )); do
    aurget_one $1
    shift
  done
}
