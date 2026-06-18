#!/bin/bash

calendar=(
  icon.drawing=off
  icon.padding_right=0
  label.color=$BLUE
  label.font="$FONT:Bold:16.0"
  label.align=right
  padding_left=3
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right \
  --set calendar "${calendar[@]}" \
  --subscribe calendar system_woke
