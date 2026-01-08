#!/bin/bash

killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ "$m" = "DP-1-5" ]; then
      # Monitor 4K principal - barras maiores
      echo "Monitor 4K principal - barras maiores"
      MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload top &
      MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload bottom &
    else
      echo "Monitores menores (DP-1-6 e eDP-1) - barras menores"
      MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload top-small &
      MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload bottom-small &
    fi
  done
else
  echo "Monitor único - barras maiores"
  polybar -c ~/.config/polybar/config.ini --reload top &
  polybar -c ~/.config/polybar/config.ini --reload bottom &
fi

echo "Polybar launched..."