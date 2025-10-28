#!/bin/bash
# Media notifications with album art (Spotify, mpv, VLC, etc.)
# Anti-spam version: updates only on song change or play/pause

tmp_dir="/tmp/medianotify"
mkdir -p "$tmp_dir"

# Check dependencies
for cmd in playerctl curl notify-send; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Error: $cmd not found."
    exit 1
  }
done

last_track=""
last_status=""

send_notification() {
  local status="$1"
  local title="$2"
  local artist="$3"
  local art_url="$4"

  local icon="🎵"
  case "$status" in
    "Playing") icon="▶️" ;;
    "Paused") icon="⏸️" ;;
    "Stopped") icon="⏹️" ;;
  esac

  local cover_img=""
  if [[ "$art_url" =~ ^https?:// ]]; then
    cover_img="$tmp_dir/cover.jpg"
    curl -sL "$art_url" -o "$cover_img" >/dev/null 2>&1
  elif [[ "$art_url" =~ ^file:// ]]; then
    cover_img="${art_url#file://}"
  fi

  local body="${title:-Unknown Track}\n${artist:-Unknown Artist}"
  local title_text="$icon $status"

  if [[ -f "$cover_img" ]]; then
    notify-send -u low -t 2500 \
      -h string:x-canonical-private-synchronous:media \
      -i "$cover_img" "$title_text" "$body"
  else
    notify-send -u low -t 2500 \
      -h string:x-canonical-private-synchronous:media \
      "$title_text" "$body"
  fi
}

while true; do
  # Fetch everything in sync
  status=$(playerctl status 2>/dev/null)
  title=$(playerctl metadata title 2>/dev/null)
  artist=$(playerctl metadata artist 2>/dev/null)
  trackid=$(playerctl metadata mpris:trackid 2>/dev/null)
  art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

  # Only notify if new track or play/pause state changed
  if [[ "$trackid" != "$last_track" || "$status" != "$last_status" ]]; then
    send_notification "$status" "$title" "$artist" "$art_url"
    last_track="$trackid"
    last_status="$status"
  fi

  sleep 1
done
