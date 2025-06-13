#!/usr/bin/env bash

set -euo pipefail

main () {
  install_homebrew
  install_homebrew_packages
  create_symlinks
  install_neovim_plugins
}

install_homebrew () {
  if command -v brew &> /dev/null; then
    echo "homebrew is already installed."
  else
    echo "intalling homebrew with curl..."
    /usr/bin/env bash -c\
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_homebrew_packages () {
  homebrew_packages=(
    "sheldon"
    "neovim"
    "nodenv"
    "pnpm"
    "bat"
  )

  for package in "${homebrew_packages[@]}"; do
    if brew list $package &>/dev/null; then
      echo "$package is already installed."
    else
      echo "intalling $package with homebrew..."
      brew install $package
    fi
  done
}

create_symlinks () {
  version_controlled_items=(
    # files
    ".zshrc"
    ".vimrc"
    ".gitconfig"
    # ".tmux.conf"
    ".config/starship.toml"

    # directories
    ".zsh"
    ".config/nvim"
    ".config/sheldon"
  )

  for item in "${version_controlled_items[@]}"; do
    if [[ -L "$HOME/$item" ]]; then
      if [[ ! -e "$HOME/$item" ]]; then
        # silently remove symlink if its target is non-existent
        rm -f "$HOME/$item"
      else
        echo "'$HOME/$item' is an existent symlink with a valid target."
        if prompt_yes_no; then rm -f "$HOME/$item"; fi
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

install_neovim_plugins () {
  if [[ -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]]; then
    echo "packer neovim plugin is already already installed."
  else
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
      ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  fi
}

prompt_yes_no() {
  while true; do
    read -rp "Do you want to delete it? [y/N]: " response

    case "$response" in
      # matches 'y', 'Y', 'yes', 'YES', etc.
      [yY][eE][sS]|[yY])
        return 0
        ;;
      # matches 'n', 'N', 'no', 'NO', etc.
      [nN][oO]|[nN])
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main

  echo "setup complete. shell restart required."
fi
