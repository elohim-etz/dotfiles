#!/bin/bash
# brightnesscontrol.sh — Elegant brightness control for Hyprland
# Dependencies: brightnessctl, notify-send (libnotify)

STEP="5%"

# Adjust brightness
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

# Get current and max brightness
current=$(brightnessctl get)
max=$(brightnessctl max)
percent=$((current * 100 / max))

# Choose icon based on brightness level
if (( percent >= 90 )); then
  icon="🌕"
elif (( percent >= 70 )); then
  icon="🌖"
elif (( percent >= 50 )); then
  icon="🌔"
elif (( percent >= 30 )); then
  icon="🌓"
elif (( percent >= 10 )); then
  icon="🌒"
else
  icon="🌑"
fi

# Create progress bar (10 segments)
progress=$(printf "%0.s█" $(seq 1 $((percent / 10))))
empty=$(printf "%0.s░" $(seq 1 $((10 - percent / 10))))

# Send notification (replace old one)
notify-send -u low -t 900 -h string:x-canonical-private-synchronous:brightness \
  "Brightness ${percent}%" "$icon  ${progress}${empty}"
