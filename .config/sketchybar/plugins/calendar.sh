#!/bin/bash

DAY=$(date '+%d')
TIME=$(date '+%l:%M' | sed 's/^ *//')
LABEL="${DAY} • ${TIME}"

sketchybar --set $NAME icon.drawing=off label="$LABEL"
