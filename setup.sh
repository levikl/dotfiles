#!/usr/bin/env bash
# vim: filetype=bash

set -euo pipefail

main() {
  set_os
  os_specific_setup
  create_symlinks
}

set_os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) OS="linux" ;;
  Darwin*) OS="mac" ;;
  *) fail "Unsupported OS: ${unameOut}" ;;
  esac
}

os_specific_setup() {
  case "$OS" in
  linux) linux ;;
  mac) mac ;;
  esac
}

linux() {
  sudo pacman -Rns --noconfirm dunst || true
  sudo rm /usr/share/applications/kitty-open.desktop || true
  sudo pacman -S --noconfirm --needed $(cat pacman.pkgs)
  sudo pacman -S --noconfirm --needed rustup

  # todo: install paru
  echo "todo: install paru packages"

  echo "-------"
  echo "make sure to run \`nwg-look\` once to initialize dark/light mode"
  echo "-------"

  if [ ! -d "$HOME/.winemonogame" ]; then
    sudo ln -s /usr/bin/wine /usr/local/bin/wine64
    wget -qO- https://monogame.net/downloads/net8_mgfxc_wine_setup.sh | bash
  fi

  xdg-mime default org.kde.dolphin.desktop inode/directory
  xdg-mime default org.kde.gwenview.desktop image/png image/jpeg

  XDG_MENU_PREFIX=arch- kbuildsycoca6
}

mac() {
  install_homebrew
  install_homebrew_packages
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "homebrew is already installed."
  else
    echo "installing homebrew with curl..."
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_homebrew_packages() {
  echo "installing homebrew packages from Brewfile..."
  brew bundle install --file=Brewfile
}

create_symlinks() {
  shared_items=(
    # files
    ".zshrc"
    ".zprofile"
    ".ideavimrc"
    ".gitconfig"
    ".gitignore_global"
    ".config/starship.toml"

    # directories
    ".zsh"
    ".config/nvim"
    ".config/sheldon"
    ".config/tmux"
    ".config/ghostty"
  )

  linux_items=(
    # files
    ".config/kwalletrc"
    ".local/bin/fix-es-de"
    ".local/bin/audit-check"

    # directories
    ".config/hypr"
    ".config/rofi"
    ".config/swaync"
    ".config/waybar"
  )

  mac_items=(
    # directories
    ".config/skhd"
    ".config/yabai"
    ".config/raycast"
    ".config/karabiner"
    ".config/sketchybar"
    ".config/linearmouse"
  )

  version_controlled_items=("${shared_items[@]}")
  case "$OS" in
  linux) version_controlled_items+=("${linux_items[@]}") ;;
  mac) version_controlled_items+=("${mac_items[@]}") ;;
  esac

  for item in "${version_controlled_items[@]}"; do
    if [[ -L "$HOME/$item" ]]; then
      if [[ ! -e "$HOME/$item" ]]; then
        # silently remove symlink if its target is non-existent
        rm -f "$HOME/$item"
      # else
      #   echo "'$HOME/$item' is an existent symlink with a valid target."
      #   if prompt_yes_no; then rm -f "$HOME/$item"; fi
      fi
    else
      if [[ -d "$HOME/$item" ]]; then
        echo "'$HOME/$item' is an existent directory."
        if prompt_yes_no; then rm -rf "$HOME/$item"; fi
      fi

      if [[ -f "$HOME/$item" ]]; then
        echo "'$HOME/$item' is an existent file."
        if prompt_yes_no; then rm -f "$HOME/$item"; fi
      fi
    fi

    if [[ ! -e "$HOME/$item" ]]; then
      echo "creating symlink for $item"
      mkdir -p "$(dirname "$HOME/$item")" # create parent directories if they don't exist
      ln -s "$HOME/dotfiles/$item" "$HOME/$item"
    fi
  done
}

prompt_yes_no() {
  while true; do
    read -rp "Do you want to delete it? [y/N]: " response

    case "$response" in
    # matches 'y', 'Y', 'yes', 'YES', etc.
    [yY][eE][sS] | [yY])
      return 0
      ;;
    # matches 'n', 'N', 'no', 'NO', etc.
    [nN][oO] | [nN])
      return 1
      ;;
    # empty input (ie. user pressed Enter)
    "")
      return 1 # default choice is No
      ;;
    # all other cases (ie. invalid input)
    *)
      echo "Invalid input. Please enter 'y' or 'n'."
      ;;
    esac
  done
}

function fail {
  printf '%s\n' "$1" >&2
  exit "${2-1}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main

  echo "setup complete."
fi
