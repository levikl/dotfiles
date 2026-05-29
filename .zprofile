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

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# .NET
export DOTNET_ROOT=/usr/share/dotnet
export PATH="$HOME/.dotnet/tools:$PATH"

# pnpm
export PNPM_HOME="/home/levi/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# composer (php)
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# go
export PATH="$(go env GOPATH)/bin:$PATH"

# podman
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"

# pnpm
export PNPM_HOME="/home/levi/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# keep .local last
export PATH="$HOME/.local/bin:$PATH"
