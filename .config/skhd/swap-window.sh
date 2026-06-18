#!/bin/bash

DIR="${1#--}"

if [[ ! "$DIR" =~ ^(west|south|north|east)$ ]]; then
  echo "Usage: $0 --{west|south|north|east}"
  exit 1
fi

case "$DIR" in
  west)  OPP=east  ;;
  east)  OPP=west  ;;
  north) OPP=south ;;
  south) OPP=north ;;
esac

if yabai -m window --swap "$DIR" 2>/dev/null; then
  # swap succeeded in-space: focus warmup to keep focus on the moved window
  yabai -m window --focus "$OPP" 2>/dev/null
  yabai -m window --focus "$DIR" 2>/dev/null
else
  # no neighbor in that direction within the space: push to external display
  yabai -m window --display "$DIR" 2>/dev/null && yabai -m display --focus "$DIR" 2>/dev/null
fi
