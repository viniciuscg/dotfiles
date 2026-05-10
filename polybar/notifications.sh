#!/bin/bash

count=$(dunstctl count waiting 2>/dev/null || echo "0")
history=$(dunstctl count displayed 2>/dev/null || echo "0")
total=$((count + history))

if [ "$total" -eq "0" ]; then
    echo "󰂚 "
else
    echo "󰂚 $total"
fi
