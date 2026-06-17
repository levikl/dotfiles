#!/bin/bash

if pgrep -x "caffeinate" >/dev/null; then
  pkill -x caffeinate
  osascript -e 'display notification "Your Mac will now sleep normally." with title "Caffeine Disabled"'
else
  caffeinate -d &
  osascript -e 'display notification "Your Mac is being kept awake." with title "Caffeine Enabled"'
fi
