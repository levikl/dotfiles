#!/bin/bash

DAY=$(date '+%d')
TIME=$(date '+%H:%M')
LABEL="${DAY} • ${TIME}"

sketchybar --set $NAME icon.drawing=off label="$LABEL"
