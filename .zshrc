#!/usr/bin/env zsh

zmodload zsh/complist
autoload -U compinit && compinit
autoload -U colors && colors
# autoload -U tetris

setopt append_history inc_append_history share_history # better history
setopt extended_glob # match ~ # ^
setopt beep
setopt nomatch
setopt notify
setopt extendedglob
unsetopt prompt_sp # don't autoclean blanklines
unsetopt auto_cd # require cd to change dir

source <(sheldon source)

# load local config
[ -f ~/.local/zshrc ] && . ~/.local/zshrc

eval "$(starship init zsh)"

# this is vim mode
bindkey -v
