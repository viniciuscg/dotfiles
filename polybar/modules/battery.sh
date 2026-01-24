#!/usr/bin/bash
# ~/.config/polybar/modules/battery.sh

ACPI_OUTPUT=$(acpi -b 2>/dev/null)

# Se não tem bateria, não mostra nada
if [[ -z "$ACPI_OUTPUT" ]]; then
    exit 0
fi

STATUS=$(echo "$ACPI_OUTPUT" | awk '{print $3}' | tr -d ',')
CHARGE=$(echo "$ACPI_OUTPUT" | grep -oP '\d+(?=%)' | head -1)

# Ícones baseados na carga
if [[ "$STATUS" == "Charging" ]]; then
    if [[ $CHARGE -ge 90 ]]; then
        ICON="󰂅"
    elif [[ $CHARGE -ge 70 ]]; then
        ICON="󰂋"
    elif [[ $CHARGE -ge 50 ]]; then
        ICON="󰂉"
    elif [[ $CHARGE -ge 30 ]]; then
        ICON="󰂇"
    else
        ICON="󰂆"
    fi
else
    if [[ $CHARGE -ge 90 ]]; then
        ICON="󰁹"
    elif [[ $CHARGE -ge 70 ]]; then
        ICON="󰂀"
    elif [[ $CHARGE -ge 50 ]]; then
        ICON="󰁾"
    elif [[ $CHARGE -ge 30 ]]; then
        ICON="󰁼"
    elif [[ $CHARGE -ge 10 ]]; then
        ICON="󰁺"
    else
        ICON="󰂃"
    fi
fi

echo "$ICON $CHARGE%"