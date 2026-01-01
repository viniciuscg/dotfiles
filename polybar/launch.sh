#!/bin/bash

killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload top &
    MONITOR=$m polybar -c ~/.config/polybar/config.ini --reload bottom &
  done
else
  polybar -c ~/.config/polybar/config.ini --reload top &
  polybar -c ~/.config/polybar/config.ini --reload bottom &
fi

echo "Polybar launched..."