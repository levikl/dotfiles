#!/usr/bin/env bash

# Usage: ./hyprzoom <in|out|reset> [step]

action=$1
step=${2:-0.1}

# Get current zoom factor
current_zoom=$(hyprctl getoption cursor:zoom_factor | grep 'float' | awk '{print $2}')

# Calculate new zoom
case "$action" in
in)
  new_zoom=$(echo "$current_zoom + $step" | bc)
  ;;
out)
  new_zoom=$(echo "$current_zoom - $step" | bc)
  # Prevent zooming out past 1.0 (default)
  if (($(echo "$new_zoom < 1.0" | bc -l))); then
    new_zoom=1.0
  fi
  ;;
reset)
  new_zoom=1.0
  ;;
*)
  echo "Usage: $0 {in|out|reset} [step]"
  exit 1
  ;;
esac

# Apply the zoom
hyprctl keyword cursor:zoom_factor "$new_zoom"
