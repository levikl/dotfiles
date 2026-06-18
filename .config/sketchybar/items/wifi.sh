#!/bin/bash

source "$CONFIG_DIR/icons.sh"

wifi=(
  padding_right=0
  padding_left=5
  label.width=0
  icon="$WIFI_DISCONNECTED"
  script="$PLUGIN_DIR/wifi.sh"
)

status_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_1
  background.corner_radius=5
)

sketchybar --add item wifi right \
  --set wifi "${wifi[@]}" \
  --subscribe wifi wifi_change mouse.clicked

sketchybar --add bracket status battery ram volume_icon wifi \
  --set status "${status_bracket[@]}"
