#!/bin/bash
# brightnesscontrol.sh — Adjust screen brightness and show notification

# Usage:
#   brightnesscontrol.sh up
#   brightnesscontrol.sh down

STEP="1%"

case "$1" in
  up)
    brightnessctl set +$STEP -q
    ;;
  down)
    brightnessctl set $STEP- -q
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac

# Get brightness percentage
br=$(brightnessctl get)
max=$(brightnessctl max)
percent=$((br * 100 / max))

# Choose icon
if (( percent > 80 )); then
  icon="🌕"
elif (( percent > 40 )); then
  icon="🌔"
elif (( percent > 10 )); then
  icon="🌓"
else
  icon="🌒"
fi

# Send notification
notify-send -u low -t 800 -h string:x-canonical-private-synchronous:brightness \
  "Brightness $icon" "${percent}%"
