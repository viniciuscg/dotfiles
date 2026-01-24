#!/bin/bash
# Get brightness percentage
current=$(brightnessctl get 2>/dev/null || echo "0")
max=$(brightnessctl max 2>/dev/null || echo "100")

if [ "$max" -eq 0 ]; then
    echo "0"
    exit 0
fi

percent=$((current * 100 / max))
echo "$percent"
