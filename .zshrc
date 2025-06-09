#!/usr/bin/env zsh
# uncomment this and the last line for zprof info
# zmodload zsh/zprof

# Lines configured by zsh-newuser-install
setopt beep extendedglob nomatch notify
unsetopt autocd

# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/levi/.zshrc'
# End of lines added by compinstall

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit

# https://gist.github.com/ctechols/ca1035271ad134841284
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done

compinit -C

source <(sheldon source)

# load local config
[ -f ~/.local/zshrc ] && . ~/.local/zshrc

eval "$(starship init zsh)"

# this is vim mode
bindkey -v

# zprof


# pnpm
#export PNPM_HOME="/Users/levi/Library/pnpm"
#case ":$PATH:" in
#  *":$PNPM_HOME:"*) ;;
#  *) export PATH="$PNPM_HOME:$PATH" ;;
#esac
# pnpm end

# bun completions
[ -s "/Users/levi/.bun/_bun" ] && source "/Users/levi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# flags for rust linker
export LDFLAGS="-L/usr/local/opt/llvm/lib $LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/llvm/include $CPFLAGS"

# sqlite (from homebrew) 
export PATH="/usr/local/opt/sqlite/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/sqlite/lib $LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/sqlite/include $CPPFLAGS"

# postgres (from homebrew)
export PATH="/usr/local/Cellar/postgresql@16/16.4/bin:$PATH"
