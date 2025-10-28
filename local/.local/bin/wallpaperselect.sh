#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers"

# If directory doesn't exist, exit
[ ! -d "$WALLPAPER_DIR" ] && notify-send "No wallpapers found in $WALLPAPER_DIR" && exit 1

# Get wallpaper list
SELECTED=$(ls "$WALLPAPER_DIR" | wofi --show dmenu --prompt "Select wallpaper:")

# If cancelled
[ -z "$SELECTED" ] && exit 0

# Apply wallpaper using swww
swww img "$WALLPAPER_DIR/$SELECTED" --transition-type random --transition-duration 1

# Optional: send notification
notify-send "Wallpaper changed" "$SELECTED"
