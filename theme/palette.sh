#!/usr/bin/env bash
# 🎨 Paleta "Dirt" — fonte única das cores para scripts shell.
# Configs que não leem variáveis de ambiente (kitty, i3, polybar, rofi, dunst,
# tmux) repetem estes valores; a tabela no README mapeia cada um.
# shellcheck disable=SC2034

# Fundos (do mais fundo ao mais elevado)
DIRT_BG0="#110e0b"  # barra, bordas inativas, lock
DIRT_BG="#1a1613"   # terminal, menus, notificações
DIRT_BG1="#241e19"  # campos de entrada, item selecionado
DIRT_BG2="#2f2722"  # destaque sutil
DIRT_LINE="#3b322b" # linhas e bordas

# Texto
DIRT_GRAY="#7c6f64"
DIRT_FG_DIM="#a89984"
DIRT_FG="#d4be98"
DIRT_FG_BRIGHT="#e6d5b3"

# Acentos (todos dessaturados)
DIRT_ACCENT="#b8652f" # laranja Gruvbox apagado
DIRT_ACCENT_DIM="#7a4524"
DIRT_RED="#8e3b3b" # bordô
DIRT_RED_BRIGHT="#a85050"
DIRT_GREEN="#7f8448" # oliva
DIRT_GREEN_BRIGHT="#9a9c62"
DIRT_YELLOW="#b08a3e" # ocre
DIRT_YELLOW_BRIGHT="#c9a35a"
DIRT_BLUE="#6f8584" # aço
DIRT_BLUE_BRIGHT="#8a9e9b"
DIRT_MAGENTA="#8a6c75" # malva
DIRT_MAGENTA_BRIGHT="#a5858f"
DIRT_CYAN="#6e8a6f" # sálvia
DIRT_CYAN_BRIGHT="#88a389"
