#!/bin/bash

aurget_one() {
  cd /tmp/aur_repos
  if ! pacman -Q $1; then
    git clone --depth 1 https://aur.archlinux.org/$1.git
    cd $1
    sed -n '/^.*depends = .*$/p' .SRCINFO > tren1
    sed '/^.*optdepends = .*$/d' tren1 > tren2
    sed 's/^.*depends = \(.*\)$/\1/' tren2 > tren3
    # sed -e 's/^.*makedepends = \(.*\)$/\1/' -e '/^.*depends = .*$/d' tren2 > tren3
    # sed -e '/^.*makedepends = .*$/d' -e 's/^.*depends = \(.*\)$/\1/' tren2 > tren6
    while read hahm; do
      if ! pacman -Q $hahm; then
        printf "$hahm\n" >> tren4
      fi
    done < tren3
    if [ -e tren4 ]; then
      local dpd_list="$(tr '\n' ' ' < tren4)"
      rm tren4
      if ! sudo pacman -S --noconfirm --needed $dpd_list; then
        echo "Sorry, pacman failed. Aborting.\n"
        return 1
      fi
    fi
    rm tren1 tren2 tren3
    sed -n '/^.*validpgpkeys = .*$/p' .SRCINFO > tren1
    sed 's/^.*validpgpkeys = \([[:alnum:]]\+\).*$/\1/' tren1 > tren2
    sed 's/^.*\(................\)$/\1/' tren2 > tren3
    while read ano_pgp; do
      if ! gpg --recv-keys $ano_pgp; then
        echo "Sorry, gpg failed. Aborting.\n"
        return 1
      fi
    done < tren3
    rm tren1 tren2 tren3
    # local pdpdl="$(tr '\n' ' ' < tren6)"
    if ! sudo makepkg -do; then
      echo "Sorry, makepkg failed. Aborting.\n"
      return 1
    fi
    makepkg -e
    find . -maxdepth 1 -type f -iregex "^\./$1.*\.pkg\.tar\.zst$" > tren5
    local pkg_name="$(sed -n '1p' tren5)"
    rm tren5
    if ! sudo pacman -U --noconfirm --needed --verbose "$pkg_name"; then
      echo "Sorry, pacman failed. Aborting.\n"
      return 1
    fi
    rm -rf /tmp/aur_repos/*
    echo "Success.\n"
  fi
}

aurget() {
  if [ "$EUID" -eq 0 ]; then
    echo "    You shouldn't run this command as root. Aborting.\n"
    return 1
  fi
  if ! [ -d /tmp/aur_repos ]; then mkdir /tmp/aur_repos; fi
  if ! [ -d /tmp/aur_repos ]; then
    echo "    Sorry, can't create /tmp/aur_repos. Aborting.\n"
    return 1
  fi
  while (( $# )); do
    aurget_one $1
    shift
  done
}
