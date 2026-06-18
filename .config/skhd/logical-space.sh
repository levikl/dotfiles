#!/bin/bash

# Focus/move/map spaces by a logical hotkey number, independent of macOS's
# global space numbering.
#
# macOS numbers spaces globally in display-arrangement (row-major) order, which
# on this machine is ultrawide -> external -> macbook. This script defines its
# own labeling instead, in two zones:
#   - Front  (ultrawide -> macbook -> any other display): ascending 1, 2, 3, ...
#   - Anchor (second external):  descending from 10 (oldest space = 10, each
#     newer one takes the next lower number: 9, 8, ...).
# It reads live yabai state, so labels track spaces being created/destroyed.
#
# Usage:
#   logical-space.sh --focus <label>   focus the space with that hotkey label
#   logical-space.sh --move  <label>   move window to that space, then follow
#   logical-space.sh --map             print "<label> <global-space-index>" lines

ACTION="${1#--}"
POS="$2"

if [[ ! "$ACTION" =~ ^(focus|move|map)$ ]] \
  || { [[ "$ACTION" != "map" ]] && [[ ! "$POS" =~ ^[0-9]+$ ]]; }; then
  echo "Usage: $0 --{focus|move} <label> | --map"
  exit 1
fi

# Front display order, by stable display UUID.
ORDER=(
  "38826603-725F-4024-A18F-9435EF5F12A8" # ultrawide
  "37D8832A-2D66-02CA-B9F7-8F30A301B230" # macbook built-in
)
# Anchor display: labeled descending from ANCHOR_START.
REVERSE_ANCHOR_UUID="F85610BA-380C-4572-BCAB-2D3FF65FF22D" # second external
ANCHOR_START=10

# Print "<label> <global-space-index>" lines for every existing space.
logical_map() {
  local displays known uuid s label i
  displays="$(yabai -m query --displays)"

  # Front zone: ascending from 1, across the listed displays then any others
  # not named here (degrades gracefully on other setups). Excludes the anchor.
  label=1
  for uuid in "${ORDER[@]}"; do
    [[ "$uuid" == "$REVERSE_ANCHOR_UUID" ]] && continue
    while read -r s; do
      [[ -n "$s" ]] || continue
      echo "$label $s"
      label=$((label + 1))
    done < <(jq -r --arg u "$uuid" '.[] | select(.uuid == $u) | .spaces[]' <<<"$displays")
  done
  known="$(printf '%s\n' "${ORDER[@]}" "$REVERSE_ANCHOR_UUID" | jq -R . | jq -s .)"
  while read -r s; do
    [[ -n "$s" ]] || continue
    echo "$label $s"
    label=$((label + 1))
  done < <(jq -r --argjson known "$known" \
    'sort_by(.index) | .[] | select((.uuid | IN($known[])) | not) | .spaces[]' <<<"$displays")

  # Anchor zone: descending from ANCHOR_START over the external's spaces
  # (oldest -> newest, so the oldest space is ANCHOR_START).
  i=0
  while read -r s; do
    [[ -n "$s" ]] || continue
    echo "$((ANCHOR_START - i)) $s"
    i=$((i + 1))
  done < <(jq -r --arg u "$REVERSE_ANCHOR_UUID" '.[] | select(.uuid == $u) | .spaces[]' <<<"$displays")
}

if [[ "$ACTION" == "map" ]]; then
  logical_map
  exit 0
fi

# Resolve the requested label to a global space index.
target="$(logical_map | awk -v n="$POS" '$1 == n { print $2; exit }')"
[[ -z "$target" ]] && exit 0

case "$ACTION" in
  focus) yabai -m space --focus "$target" ;;
  move)  yabai -m window --space "$target" && yabai -m space --focus "$target" ;;
esac
