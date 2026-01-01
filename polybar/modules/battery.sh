#!/usr/bin/bash

ACPI_OUTPUT=$(acpi -b)
STATUS=$(echo "$ACPI_OUTPUT" | awk '{print $3}' | tr -d ',')
CHARGE=$(echo "$ACPI_OUTPUT" | grep -oP '\d+(?=%)' | head -1)

ICON=""
FORMAT=""

if [[ "$STATUS" == "Charging" ]]; then
    ICON="󰂄  "
else
    ICON="󰁹  "
fi

if [[ $CHARGE -lt 10 ]]; then
    CHARGE_COLOR="%{F#B33D43}"
elif [[ $CHARGE -lt 30 ]]; then
    CHARGE_COLOR="%{F#F27F24}"
elif [[ $CHARGE -lt 60 ]]; then
    CHARGE_COLOR="%{F#E5C167}"
elif [[ $CHARGE -lt 100 ]]; then
    CHARGE_COLOR="%{F#6FB379}"
else
    CHARGE_COLOR="%{F#6FB379}"
fi

FORMAT="$CHARGE_COLOR $ICON $CHARGE%%{F-}"

echo $FORMAT
