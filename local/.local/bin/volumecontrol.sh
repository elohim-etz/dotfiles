#!/bin/bash
#
step=5%  # Volume step

get_volume() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

is_muted() {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

get_mic_mute() {
  wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED
}

case "$1" in
  up)
    vol=$(get_volume)
    if [ "$vol" -lt 100 ]; then
      wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$step"+ >/dev/null
    fi
    ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$step"- >/dev/null
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null
    ;;
  micmute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null
    micmuted=$(get_mic_mute && echo "yes" || echo "no")

    if [ "$micmuted" = "yes" ]; then
      notify-send -u low -t 900 -h string:x-canonical-private-synchronous:mic \
        "Microphone" "Muted 🎙️❌"
    else
      notify-send -u low -t 900 -h string:x-canonical-private-synchronous:mic \
        "Microphone" "Unmuted 🎙️✅"
    fi
    exit 0
    ;;
  *)
    echo "Usage: $0 {up|down|mute|micmute}"
    exit 1
    ;;
esac

# Get new volume and mute status
vol=$(get_volume)
is_muted && muted="yes" || muted="no"

# Progress bar
progress=$(printf "%0.s█" $(seq 1 $((vol / 10))))
empty=$(printf "%0.s░" $(seq 1 $((10 - vol / 10))))

# Send volume notification
if [ "$muted" = "yes" ]; then
  notify-send -u low -t 900 -h string:x-canonical-private-synchronous:volume \
    "Volume" "Muted"
else
  notify-send -u low -t 900 -h string:x-canonical-private-synchronous:volume \
    "Volume ${vol}%" "${progress}${empty}"
fi
