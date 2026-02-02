#!/usr/bin/env bash

PRIMARY=""

if xrandr | grep -q "DP-1-5 connected"; then
  PRIMARY="DP-1-5"
elif xrandr | grep -q "^HDMI-1 connected"; then
  PRIMARY="HDMI-1"
elif xrandr | grep -q "^eDP-1 connected"; then
  PRIMARY="eDP-1"
fi

if [ -n "$PRIMARY" ]; then
  xrandr --output "$PRIMARY" --primary --auto
fi
