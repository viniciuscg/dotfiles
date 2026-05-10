#!/bin/bash

chosen=$(printf "Full Screen\nSelect Region\nActive Window" | \
  rofi -dmenu \
       -p "Screenshot" \
       -theme ~/.config/rofi/topmenu.rasi)

case "$chosen" in
  "Full Screen")
    sleep 0.5
    scrot ~/Pictures/Screenshots/screenshot_%Y%m%d_%H%M%S.png
    notify-send "Screenshot" "Full screen saved!" ;;
  "Select Region")
    sleep 0.5
    scrot -s ~/Pictures/Screenshots/screenshot_%Y%m%d_%H%M%S.png
    notify-send "Screenshot" "Region saved!" ;;
  "Active Window")
    sleep 0.5
    scrot -u ~/Pictures/Screenshots/screenshot_%Y%m%d_%H%M%S.png
    notify-send "Screenshot" "Window saved!" ;;
esac
