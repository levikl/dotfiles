#!/bin/bash

ram=(
  script="$PLUGIN_DIR/ram.sh"
  icon.font="$FONT:Regular:16.0"
  icon="$RAM"
  padding_right=0
  padding_left=0
  icon.padding_left=2
  icon.padding_right=1
  label.padding_left=0
  update_freq=5
)

sketchybar --add item ram right \
  --set ram "${ram[@]}"
