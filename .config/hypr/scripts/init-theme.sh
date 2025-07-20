#!/usr/bin/env bash

gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

themeState="$HOME/.local/state/hypr/theme"

if [ -f "$themeState" ] && [ "$(cat $themeState)" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi
