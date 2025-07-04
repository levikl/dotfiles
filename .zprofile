if hash nvim 2>/dev/null; then
  export EDITOR=nvim

  # Use nvim as manpager `:h Man`
  export MANPAGER='nvim +Man!'
else
  export EDITOR=vim
fi

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
