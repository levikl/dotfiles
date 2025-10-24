if hash nvim 2>/dev/null; then
  export EDITOR=nvim

  # Use nvim as manpager `:h Man`
  export MANPAGER='nvim +Man!'
else
  export EDITOR=vim
fi

# monogame + wine
export MGFXC_WINE_PATH="$HOME/.winemonogame"

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"

# nodenv
export NODENV_ROOT="$HOME/.nodenv"
export PATH="$NODENV_ROOT/bin:$PATH"

# .NET
export DOTNET_ROOT=/usr/share/dotnet
export PATH="$HOME/.dotnet/tools:$PATH"

# keep .local last
export PATH="$HOME/.local/bin:$PATH"
