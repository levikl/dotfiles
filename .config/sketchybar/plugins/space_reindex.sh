#!/bin/bash

# Relabel + reorder the sketchybar space items so their numbers match the logical
# hotkey labels from ~/.config/skhd/logical-space.sh (front zone ascending from 1;
# external zone descending from 10), rather than macOS's global space numbers.
# Items are ordered left-to-right by label ascending, so the bar reads e.g.
# "1 2 3 8 9 10" with the external block anchored on the right.
#
# Driven by space_change / display_change / the custom space_reindex event, so it
# tracks spaces being created/destroyed as the mapping shifts.

map="$(~/.config/skhd/logical-space.sh --map)"
[[ -z "$map" ]] && exit 0

# Relabel each space to its logical label.
set_args=()
while read -r label global; do
  [[ -n "$label" ]] || continue
  set_args+=(--set "space.$global" icon="$label")
done <<<"$map"

# Reorder items by label ascending (gaps are fine).
order=()
while read -r label global; do
  [[ -n "$label" ]] || continue
  order+=("space.$global")
done < <(sort -n <<<"$map")

# Batch the relabels, then fix the visual order, to avoid flicker.
sketchybar "${set_args[@]}"
[[ ${#order[@]} -gt 1 ]] && sketchybar --reorder "${order[@]}"
