#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

# List of files/directories to symlink
files=(
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

for dest in "${files[@]}"; do
  if [ -e "$HOME/$dest" ]; then
    echo "Skipping $HOME/$dest, already exists."
  else
    echo "Creating symlink for $dest to $HOME/$dest"
    ln -s "$DOTFILES_DIR/$dest" "$HOME/$dest"
  fi
done

echo "Dotfiles setup complete!"
