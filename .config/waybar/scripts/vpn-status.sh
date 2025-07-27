#!/usr/bin/env bash
# vim: filetype=bash

get_text () {
  ip add show | grep -qF proton0 && echo "ᴠᴘɴ" || echo ""
}

get_tooltip () {
  apiToken=$(pass api.findip.net)
  ipAddr=$(curl https://api.ipify.org)
  location=$(curl "https://api.findip.net/${ipAddr}/?token=${apiToken}")

  country_code=$(echo $location | jq -r '.country.iso_code' | tr '[:lower:]' '[:upper:]')
  if ! [[ "$country_code" =~ ^[A-Z]{2}$ ]]; then
    echo "Error: Please provide a valid two-letter country code."
    return 1
  fi

  char1=$(printf "%d" "'${country_code:0:1}")
  char2=$(printf "%d" "'${country_code:1:1}")

  # the Unicode value for Regional Indicator Symbol 'A' is 127462 (0x1F1E6)
  # the ASCII value for 'A' is 65
  # take offset from 'A' and add it to the base Unicode value
  local offset=127397 # 127462 - 65

  city=$(echo $location | jq -r '.city.names.en')
  state=$(echo $location | jq -r '.subdivisions[0].iso_code')
  country_flag=$(printf "\\U%X\\U%X" $((char1 + offset)) $((char2 + offset)))

  printf "${city}, ${state}, ${country_flag}"
}

text=$(get_text)
tooltip=$(get_tooltip)

printf "${text}\n${tooltip}\n"

