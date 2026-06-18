#!/usr/bin/env bash
# vim: filetype=bash

set -euo pipefail

main() {
  os_specific_update
}

os_specific_update() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) linux ;;
  Darwin*) mac ;;
  *) fail "Unsupported OS: ${unameOut}" ;;
  esac
}

linux() {
  # TODO: implement linux update (e.g. pacman -Syu, refresh pacman.pkgs)
  echo "todo: linux update not yet implemented"
}

mac() {
  echo "updating homebrew..."
  brew update

  echo "upgrading homebrew packages..."
  brew upgrade

  echo "cleaning up old versions..."
  brew cleanup

  echo "regenerating Brewfile..."
  brew bundle dump --force --file=Brewfile
}

function fail {
  printf '%s\n' "$1" >&2
  exit "${2-1}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main

  echo "update complete."
fi
