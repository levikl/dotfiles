#!/bin/bash

current=$(yabai -m config menubar_opacity)
if [ "$current" = "0.0000" ]; then
  yabai -m config menubar_opacity 1.0
else
  yabai -m config menubar_opacity 0.0
fi
