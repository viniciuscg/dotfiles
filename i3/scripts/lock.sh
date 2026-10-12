#!/usr/bin/env bash
# 🔒 Bloqueio de tela com a cor de fundo da paleta.
# Argumentos extras vão direto pro i3lock (ex.: --nofork, usado pelo xss-lock).
set -u

# Pausa notificações enquanto a tela estiver bloqueada (se o dunst estiver rodando).
dunstctl set-paused true 2>/dev/null || true
trap 'dunstctl set-paused false 2>/dev/null || true' EXIT

# -e: ignora Enter vazio · -f: mostra tentativas erradas · -n: espera desbloquear
i3lock -n -e -f -c 110e0b "$@"
