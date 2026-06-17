#!/bin/bash

ram=(
  script="$PLUGIN_DIR/ram.sh"
  icon.font="$FONT:Regular:19.0"
  icon="􀫦"
  padding_right=0
  padding_left=0
  update_freq=5
)

sketchybar --add item ram right \
  --set ram "${ram[@]}"
