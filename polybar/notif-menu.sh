#!/bin/bash

chosen=$(printf "Show History\nClear All\nClose" | \
  rofi -dmenu \
       -p "Notifications" \
       -theme ~/.config/rofi/topmenu.rasi)

case "$chosen" in
  "Show History")
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop ;;
  "Clear All")
    dunstctl close-all
    notify-send "Notifications" "All cleared" ;;
  "Close") exit 0 ;;
esac
