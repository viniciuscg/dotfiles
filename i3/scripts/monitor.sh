#!/usr/bin/env bash

PRIMARY=""
SECOND_MONITOR="DP-1-6"
LAPTOP_MONITOR="eDP-1"

if xrandr | grep -q "DP-1-5 connected"; then
  PRIMARY="DP-1-5"
elif xrandr | grep -q "^HDMI-1 connected"; then
  PRIMARY="HDMI-1"
elif xrandr | grep -q "^eDP-1 connected"; then
  PRIMARY="eDP-1"
fi

if [ -n "$PRIMARY" ]; then
  xrandr --output "$PRIMARY" --primary --auto --rotate normal
fi

# Keep the View 27 (DP-1-6) to the right side, normal orientation.
if [ -n "$PRIMARY" ] && [ "$PRIMARY" != "$SECOND_MONITOR" ] && xrandr | grep -q "^${SECOND_MONITOR} connected"; then
  xrandr --output "$SECOND_MONITOR" --auto --rotate normal --right-of "$PRIMARY"
fi

# Avoid output overlap: keep laptop panel to the left of the primary monitor.
if [ -n "$PRIMARY" ] && [ "$PRIMARY" != "$LAPTOP_MONITOR" ] && xrandr | grep -q "^${LAPTOP_MONITOR} connected"; then
  xrandr --output "$LAPTOP_MONITOR" --auto --rotate normal --left-of "$PRIMARY"
fi

# Reapply wallpaper after layout changes to avoid stretched/misaligned backgrounds.
if [ -x "$HOME/.config/i3/scripts/load_wallpaper.sh" ]; then
  "$HOME/.config/i3/scripts/load_wallpaper.sh"
fi
