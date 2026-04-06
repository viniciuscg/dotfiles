#!/bin/bash

killall -q polybar

CONFIG_FILE="$HOME/dotfiles/polybar/config.ini"
if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="$HOME/.config/polybar/config.ini"
fi

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ "$m" = "DP-1-5" ]; then
      # Monitor 4K principal - barras maiores
      echo "Monitor 4K principal - barras maiores"
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload top &
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload bottom &
    elif [ "$m" = "DP-1-6" ]; then
      # Monitor vertical - barras menores e centralizadas
      echo "Monitor vertical (DP-1-6) - barras compactas"
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload top-vertical &
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload bottom-vertical &
    else
      echo "Monitores menores (eDP-1) - barras menores"
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload top-small &
      MONITOR=$m polybar -c "$CONFIG_FILE" --reload bottom-small &
    fi
  done
else
  echo "Monitor único - barras maiores"
  polybar -c "$CONFIG_FILE" --reload top &
  polybar -c "$CONFIG_FILE" --reload bottom &
fi

echo "Polybar launched..."