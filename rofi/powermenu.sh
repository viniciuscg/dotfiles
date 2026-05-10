#!/bin/bash

chosen=$(printf "Shutdown\nReboot\nLogout\nLock" | \
  rofi -dmenu \
       -p "Power" \
       -theme ~/.config/rofi/topmenu.rasi)

case "$chosen" in
  "Shutdown")  systemctl poweroff ;;
  "Reboot")    systemctl reboot ;;
  "Logout")    i3-msg exit ;;
  "Lock")      ~/.config/i3/lock.sh ;;
esac

