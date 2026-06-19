#!/bin/bash

volume_slider=(
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  label.drawing=off
  icon.drawing=off
  slider.highlight_color=$BLUE
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color=$BACKGROUND_2
  slider.knob=􀀁
  slider.knob.drawing=on
)

volume_icon=(
  # click_script="$PLUGIN_DIR/volume_click.sh"
  script="$PLUGIN_DIR/volume.sh"
  padding_left=5
  padding_right=0
  icon=$VOLUME_100
  icon.align=left
  icon.color=$ORANGE
  icon.font="$FONT:Regular:14.0"
  label.padding_left=0
  label.padding_right=0
  label.align=right
  label.color=$ORANGE
)

sketchybar --add slider volume right \
  --set volume "${volume_slider[@]}" \
  --subscribe volume volume_change \
  \
  --add item volume_icon right \
  --set volume_icon "${volume_icon[@]}" \
  --subscribe volume_icon mouse.scrolled

status_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_1
  background.corner_radius=5
)

sketchybar --add bracket status battery ram volume_icon wifi \
  --set status "${status_bracket[@]}"
