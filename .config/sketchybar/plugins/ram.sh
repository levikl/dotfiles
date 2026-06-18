#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TOTAL_RAM=36

read -r USED_GB PERCENTAGE <<<$(vm_stat | awk -v tot=$(sysctl -n hw.memsize) '
  /page size of/{ps=$8} /Pages free/{fr=$3} /File-backed/{fb=$3}
  END{
    gsub(/\./,"",fr); gsub(/\./,"",fb); used=tot-(fr+fb)*ps;

    printf "%d %.0f\n", used/2^30, used/tot*100
  }
')

COLOR=$BLUE
if [ "$PERCENTAGE" -gt 85 ]; then
  COLOR=$RED
elif [ "$PERCENTAGE" -gt 65 ]; then
  COLOR=$YELLOW
fi

SWAP_USED=$(sysctl -n vm.swapusage | awk '{print $6}')

LABEL="${USED_GB}/${TOTAL_RAM}"

if [ "$SWAP_USED" != "0.00M" ]; then
  LABEL="${LABEL} [Swap: ${SWAP_USED}]"
  COLOR=$YELLOW
fi

sketchybar --set "$NAME" \
  label="$LABEL" \
  icon.color="$COLOR" \
  label.color="$COLOR"
