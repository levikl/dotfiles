if hash nvim 2>/dev/null; then
  export EDITOR=nvim

  # Use nvim as manpager `:h Man`
  export MANPAGER='nvim +Man!'
else
  export EDITOR=vim
fi

# goenv
# export GOENV_ROOT="$HOME/.goenv"
# export PATH="$GOENV_ROOT/bin:$PATH"

# nodenv
# export NODENV_ROOT="$HOME/.nodenv"
# export PATH="$NODENV_ROOT/bin:$PATH"

# keep .local last
export PATH="$HOME/.local/bin:$PATH"
