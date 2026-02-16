#!/usr/bin/env bash
# vim: filetype=bash

hi_res=('1080x0' ' 0x-1440' ' 3440x-1440,' '-1080x-1440' '0x0000FF84, preferred')
md_res=('960x0' ' 0x-1080' ' 2560x-1080,' '-1080x-1080' '0x0000FF84, 2560x1080@60')
# lo_res=('480x0' '0x-960' '3440x-960' '-1080x-960' '0x0000FF84, 2240x960@60')

hyprland_conf=/home/levi/.config/hypr/hyprland.conf

if grep -q '\-1080x-1440' $hyprland_conf; then
  declare -n a=hi_res
  declare -n b=md_res
else
  # if grep -q '\-1080x-1080' $hyprland_conf; then
  declare -n a=md_res
  # declare -n b=lo_res
  declare -n b=hi_res
  # else
  #   declare -n a=lo_res
  #   declare -n b=hi_res
  # fi
fi

for i in "${!a[@]}"; do
  echo "s/${a[$i]}/${b[$i]}/g"
  sed -i "s/${a[$i]}/${b[$i]}/g" $hyprland_conf
done
