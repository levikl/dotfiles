#!/bin/bash

DAY=$(date '+%e' | sed 's/^ *//')
TIME=$(date '+%l:%M' | sed 's/^ *//')
LABEL="${DAY} • ${TIME}"

sketchybar --set $NAME icon.drawing=off label="$LABEL"
