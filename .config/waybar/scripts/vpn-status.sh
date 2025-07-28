#!/usr/bin/env bash
# vim: filetype=bash

LOCK_FILE="/tmp/vpn_status.lock"

is_vpn_active() {
  ip add show | grep -qF proton0
}

get_tooltip() {
  (
    # using mutex lock/unlock here so only hit APIs once instead of `n` times (n = number of
    # monitors running waybar) before cached values make it into valkey
    flock -x 200

    if ! is_vpn_active; then
      cached_protonvpn_id=$(valkey-cli GET current_protonvpn_id)
      if [[ -n "$cached_protonvpn_id" ]]; then
        notify-send -t 2250 "VPN disabled" "You're going commando"
        valkey-cli DEL current_protonvpn_id current_ip has_vpn_status_notified
      fi
      return 1
    fi

    runtime_protonvpn_id=$(ip add show | grep 'proton0: ' | grep -oP '^([^:])+')
    cached_protonvpn_id=$(valkey-cli GET current_protonvpn_id)
    if [[ "$runtime_protonvpn_id" != "$cached_protonvpn_id" ]]; then
      notify-send -t 2250 "NEW VPN"
      valkey-cli DEL current_ip has_vpn_status_notified
      valkey-cli SET current_protonvpn_id "$runtime_protonvpn_id"
    fi

    current_ip=$(valkey-cli GET current_ip)
    if [[ -z "$current_ip" ]]; then
      current_ip=$(curl https://api.ipify.org)
      notify-send -t 2250 "New IP Address" "$current_ip"
      valkey-cli SET current_ip "$current_ip"
    fi

    # TODO vvv store this longterm in a sqlite db instead
    location=$(valkey-cli GET "locations.$current_ip")
    if [[ -z "$location" ]]; then
      api_token=$(pass api.findip.net)
      location=$(curl "https://api.findip.net/$current_ip/?token=$api_token")
      # notify-send -t 2250 "New location" "$location"
      valkey-cli SET "locations.$current_ip" "$location"
    fi

    country=$(echo $location | jq -r '.country.names.en')
    if [[ "$country" == "United States" ]]; then country="USA"; fi

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
    entity=$(echo $location | jq -r '.subdivisions[0].iso_code')
    country_flag=$(printf "\\U%X\\U%X" $((char1 + offset)) $((char2 + offset)))
    location_string=$(printf "$city, $entity, $country $country_flag")

    has_notified=$(valkey-cli GET has_vpn_status_notified)
    if [[ -z "$has_notified" ]]; then
      notify-send -t 2250 "VPN" "$location_string"
      valkey-cli SET has_vpn_status_notified "true"
    fi

    printf "$location_string\r$current_ip"
  ) 200>"$LOCK_FILE"
}

text=$(is_vpn_active && echo "ᴠᴘɴ" || echo "")
tooltip=$(get_tooltip)

printf "$text\n${tooltip}\n"
