#!/bin/bash

DIR="${1#--}"

if [[ ! "$DIR" =~ ^(west|south|north|east)$ ]]; then
  echo "Usage: $0 --{west|south|north|east}"
  exit 1
fi

yabai -m window --focus "$DIR" 2>/dev/null || yabai -m display --focus "$DIR" 2>/dev/null
