#!/bin/bash

run_nmtui() {
    if command -v kitty >/dev/null 2>&1; then
        kitty -e nmtui
    elif command -v alacritty >/dev/null 2>&1; then
        alacritty -e nmtui
    else
        x-terminal-emulator -e nmtui 2>/dev/null || notify-send "Network" "Instala kitty ou um terminal com nmtui"
    fi
}

chosen=$(printf "Network Settings\nWiFi On/Off\nConnect WiFi\nDisconnect" | \
  rofi -dmenu \
       -p "Network" \
       -theme ~/.config/rofi/topmenu.rasi)

case "$chosen" in
  "Network Settings")
    run_nmtui ;;
  "WiFi On/Off")
    nmcli radio wifi toggle
    notify-send "Network" "WiFi toggled" ;;
  "Connect WiFi")
    run_nmtui ;;
  "Disconnect")
    nmcli dev disconnect "$(nmcli -t -f DEVICE,STATE device | awk -F: '$2=="connected"{print $1; exit}')"
    notify-send "Network" "Disconnected" ;;
esac
