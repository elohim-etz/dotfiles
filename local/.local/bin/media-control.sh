#!/bin/bash
# media-control.sh — Media key handler for Hyprland
# Dependencies: playerctl, notify-send, jq, curl (for cover art fallback)

action=$1

if [[ -z "$action" ]]; then
  echo "Usage: $0 {play-pause|next|previous}"
  exit 1
fi

# Perform the action
case "$action" in
  play-pause)
    playerctl play-pause
    ;;
  next)
    playerctl next
    ;;
  previous)
    playerctl previous
    ;;
  *)
    echo "Usage: $0 {play-pause|next|previous}"
    exit 1
    ;;
esac

# Wait briefly for metadata to update
sleep 0.2

# Fetch metadata
player=$(playerctl -l | head -n 1)
if [[ -z "$player" ]]; then
  notify-send -u low -t 1200 "🎵 No active player" "Open a media app first."
  exit 0
fi

status=$(playerctl status 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)
arturl=$(playerctl metadata mpris:artUrl 2>/dev/null | sed 's#^file://##')

# Select appropriate icon
case "$status" in
  Playing)
    icon="▶️"
    ;;
  Paused)
    icon="⏸️"
    ;;
  *)
    icon="⏹️"
    ;;
esac

# Format message
if [[ -n "$artist" ]]; then
  line1="${title:-Unknown Title}"
  line2="${artist:-Unknown Artist}"
else
  line1="${title:-Unknown Title}"
  line2=""
fi

# If album art exists, use it in notification
if [[ -n "$arturl" && -f "$arturl" ]]; then
  notify-send -u low -t 1500 -i "$arturl" -h string:x-canonical-private-synchronous:media \
    "${icon}  ${line1}" "$line2"
else
  # Fallback with emoji if no cover art
  notify-send -u low -t 1500 -h string:x-canonical-private-synchronous:media \
    "${icon}  ${line1}" "$line2"
fi
