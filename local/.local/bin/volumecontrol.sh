#!/bin/bash

# Simple volume control with notifications
# Usage: volumecontrol.sh up | down | mute

step=5%  # change step

case "$1" in
  up)
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$step"+ >/dev/null
    ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$step"- >/dev/null
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null
    ;;
  *)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

# Get updated volume and mute status
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
mute=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no")

if [ "$mute" = "yes" ]; then
  notify-send -u low -t 800 -h string:x-canonical-private-synchronous:volume "Volume" "Muted 🔇"
else
  notify-send -u low -t 800 -h string:x-canonical-private-synchronous:volume "Volume" "${vol}% 🔊"
fi
