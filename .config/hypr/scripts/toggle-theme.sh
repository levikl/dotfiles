#!/usr/bin/env bash

themeState="$HOME/.local/state/hypr/theme"

set_light_mode() {
    echo light > $themeState
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    sed -i 's/gtk-application-prefer-dark-theme=.*$/gtk-application-prefer-dark-theme=0/g' $HOME/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=.*$/gtk-application-prefer-dark-theme=0/g' $HOME/.config/gtk-4.0/settings.ini
    sed -i 's/theme=.*$/theme=tokyonight-day/g' $HOME/.config/ghostty/config
    sed -i 's/^background=/#background=/g' $HOME/.config/ghostty/config

    # todo - kvantum + qt5/qt6 stuff
 
    notify-send -t 2250 "System theme changed" "Light mode enabled"
}

set_dark_mode() {
    echo dark > $themeState
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sed -i 's/gtk-application-prefer-dark-theme=.*$/gtk-application-prefer-dark-theme=1/g' $HOME/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=.*$/gtk-application-prefer-dark-theme=1/g' $HOME/.config/gtk-4.0/settings.ini
    sed -i 's/theme=.*$/theme=tokyonight_night/g' $HOME/.config/ghostty/config
    sed -i 's/^#background=/background=/g' $HOME/.config/ghostty/config

    # todo - kvantum + qt5/qt6 stuff

    notify-send -t 2250 "System theme changed" "Dark mode enabled"
}

if [ -f "$themeState" ] && [ "$(cat $themeState)" = "dark" ]; then
    set_light_mode
else
    set_dark_mode
fi
