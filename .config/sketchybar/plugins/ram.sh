#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PAGE_SIZE=$(pagesize)

TOTAL_RAM=36

read -r USED_GB PERCENTAGE <<<$(vm_stat | awk -v psize=$PAGE_SIZE -v total=$TOTAL_RAM '
  /Anonymous pages/ { gsub("\\.", "", $NF); anon=$NF }
  /Pages wired down/ { gsub("\\.", "", $NF); wired=$NF }
  /Pages occupied by compressor/ { gsub("\\.", "", $NF); comp=$NF }
  END {
    # Calculate total used bytes using the Activity Monitor "App Memory" formula
    used = (anon + wired + comp) * psize / 1073741824
    pct = (used / total) * 100
    
    # Output GBs (1 decimal place) and Percentage (integer)
    printf "%d %.0f\n", used, pct
  }
')

COLOR=$BLUE
if [ "$PERCENTAGE" -gt 85 ]; then
  COLOR=$RED
elif [ "$PERCENTAGE" -gt 65 ]; then
  COLOR=$YELLOW
fi

SWAP_USED=$(sysctl -n vm.swapusage | awk '{print $6}')

LABEL="${USED_GB}/${TOTAL_RAM}G"

if [ "$SWAP_USED" != "0.00M" ]; then
  LABEL="${LABEL} [Swap: ${SWAP_USED}]"
  COLOR=$YELLOW
fi

sketchybar --set "$NAME" \
  label="$LABEL" \
  icon.color="$COLOR" \
  label.color="$COLOR"
