#!/usr/bin/env bash
# 🖤 Gera o wallpaper "dirt-contours": linhas de contorno orgânicas (tipo
# entalhe/blackwork) sobre fundo marrom-quase-preto, com uma única linha em
# laranja apagado, granulação leve e vinheta. 100% gerado aqui — sem direitos
# de terceiros (domínio público / CC0).
#
# Uso: wallpaper/generate.sh [largura] [altura] [saída] [semente]
set -euo pipefail
export LC_ALL=C # números com ponto (pt_BR usaria vírgula e quebraria os kernels)

W=${1:-3840}
H=${2:-2160}
OUT=${3:-"$(dirname "$0")/dirt-contours.jpg"}
SEED=${4:-1993} # ano do Dirt

if command -v magick >/dev/null 2>&1; then IM=(magick); else IM=(convert); fi

BG="#110e0b"   # DIRT_BG0
INK="#3d3129"  # contornos: só um pouco acima do fundo
RUST="#b8652f" # DIRT_ACCENT

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 1) Campo de ruído suave (relevo). Gerado num tamanho fixo e ampliado, então
#    a composição é a mesma em qualquer resolução.
"${IM[@]}" -seed "$SEED" -size 480x270 plasma:fractal \
  -colorspace Gray -blur 0x5 -auto-level \
  -filter Mitchell -resize "${W}x${H}!" "$tmp/field.png"

# Espessura das linhas proporcional à altura (≈2px em 2160p).
LW=$(awk -v h="$H" 'BEGIN { r = h / 1080; printf "%.2f", (r < 1 ? 1 : r) }')

# 2) Curvas de nível: faixas senoidais binárias → borda de cada faixa.
"${IM[@]}" "$tmp/field.png" -function Sinusoid 14,0 -threshold 50% \
  -morphology EdgeIn Disk:"$LW" -blur 0x0.7 "$tmp/lines.png"

# 3) Uma curva só, em ferrugem (a "veia"), um pouco mais grossa.
"${IM[@]}" "$tmp/field.png" -threshold 58% \
  -morphology EdgeIn Disk:"$(awk -v w="$LW" 'BEGIN { print w * 1.6 }')" -blur 0x0.9 "$tmp/vein.png"

# 4) Máscara: detalhe forte à direita, calmo à esquerda (onde ficam as janelas).
"${IM[@]}" -size "${H}x${W}" gradient:"gray(25%)"-white -rotate -90 "$tmp/fade.png"

# 5) Composição: fundo + tinta (mascarada) + veia + grão + vinheta.
"${IM[@]}" -size "${W}x${H}" xc:"$BG" \
  \( -size "${W}x${H}" xc:"$INK" \( "$tmp/lines.png" "$tmp/fade.png" -compose Multiply -composite \) \
  -alpha off -compose CopyOpacity -composite \) -compose Over -composite \
  \( -size "${W}x${H}" xc:"$RUST" \( "$tmp/vein.png" "$tmp/fade.png" -compose Multiply -composite -evaluate Multiply 0.55 \) \
  -alpha off -compose CopyOpacity -composite \) -compose Over -composite \
  \( -size "${W}x${H}" xc:gray50 -seed "$SEED" -attenuate 0.18 +noise Gaussian -colorspace Gray \) \
  -compose SoftLight -composite \
  \( -size "${W}x${H}" radial-gradient:white-black -evaluate Pow 0.9 +level 38%,100% \) \
  -compose Multiply -composite \
  -strip -interlace JPEG -sampling-factor 4:2:0 -quality 88 "$OUT"

echo "$OUT"
