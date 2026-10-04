#!/usr/bin/env bash
# Status line do Claude Code: recebe JSON da sessão no stdin e imprime 2 linhas.
#   1: modelo · effort | pasta | branch git | contexto usado
#   2: limite 5h e semanal (assinatura Pro/Max) ou custo da sessão (API)

input=$(cat)

R='\033[0m'
rgb() { printf '\033[38;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
# mesma paleta do kitty/polybar
ACC=$(rgb '#e8e8e8'); DIM=$(rgb '#8a8a8a'); FAINT=$(rgb '#666666'); EMPTY=$(rgb '#3a3a3a')
GREEN=$(rgb '#98c379'); YELLOW=$(rgb '#e5c07b'); RED=$(rgb '#e06c75')

eval "$(jq -r '
  @sh "model=\(.model.display_name // .model.id // "?")",
  @sh "effort=\(.effort.level // "")",
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "ctx=\(.context_window.used_percentage // 0 | floor)",
  @sh "ctx_size=\(.context_window.context_window_size // 200000)",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "dur_ms=\(.cost.total_duration_ms // 0)",
  @sh "h5=\(.rate_limits.five_hour.used_percentage // "" | if . == "" then . else floor end)",
  @sh "h5_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "d7=\(.rate_limits.seven_day.used_percentage // "" | if . == "" then . else floor end)",
  @sh "d7_reset=\(.rate_limits.seven_day.resets_at // "")",
  @sh "sp=\(.rate_limits.spend_limit.used_percentage // "" | if . == "" then . else floor end)",
  @sh "sp_reset=\(.rate_limits.spend_limit.resets_at // "")"
' <<<"$input")"

# cor por faixa de uso: verde < 50, amarelo < 80, vermelho >= 80
color() { (( $1 >= 80 )) && printf '%s' "$RED" || { (( $1 >= 50 )) && printf '%s' "$YELLOW" || printf '%s' "$GREEN"; }; }

bar() {  # bar <pct> <largura>
  local pct=$1 w=${2:-10} out="" i c
  (( pct > 100 )) && pct=100
  c=$(color "$pct")
  for ((i = 0; i < w; i++)); do
    if (( pct * w / 100 > i )); then out+="${c}█"; else out+="${EMPTY}░"; fi
  done
  printf '%b' "${out}${R}"
}

# tempo até um epoch, ex.: "2h13m" ou "3d4h"
until_epoch() {
  local s=$(( $1 - $(date +%s) ))
  (( s < 0 )) && s=0
  if (( s >= 86400 )); then printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600))
  elif (( s >= 3600 )); then printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  else printf '%dm' $((s / 60)); fi
}

# --- linha 1 ---
dir=$(basename "${cwd:-?}")
line1="${ACC}${model}${R}"
[[ -n $effort ]] && line1+="${FAINT} · ${effort}${R}"
SEP="${FAINT}  ${R}"
line1+="${SEP}${DIM} ${dir}${R}"

if [[ -n $cwd ]] && branch=$(git -C "$cwd" branch --show-current 2>/dev/null) && [[ -n $branch ]]; then
  dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l)
  line1+="${SEP}${DIM} ${branch}"
  (( dirty > 0 )) && line1+=" ${YELLOW}±${dirty}"
  line1+="${R}"
fi

ctx_k=$(( ctx_size / 1000 ))
(( ctx_k >= 1000 )) && ctx_label="$((ctx_k / 1000))M" || ctx_label="${ctx_k}k"
line1+="${SEP}${DIM}󰧑 $(bar "$ctx" 10) ${DIM}${ctx}% de ${ctx_label}${R}"

# --- linha 2 ---
parts=()
[[ -n $h5 ]] && parts+=("${DIM}󱑂 5h${R} $(bar "$h5" 10) $(color "$h5")${h5}%${DIM} reseta em $(until_epoch "$h5_reset")${R}")
[[ -n $d7 ]] && parts+=("${DIM}󰃭 semana${R} $(bar "$d7" 10) $(color "$d7")${d7}%${DIM} reseta em $(until_epoch "$d7_reset")${R}")
[[ -n $sp ]] && parts+=("${DIM}󰠠 gasto${R} $(bar "$sp" 10) $(color "$sp")${sp}%${DIM} reseta em $(until_epoch "$sp_reset")${R}")

mins=$(( dur_ms / 60000 ))
parts+=("${DIM}󰄦 \$$(LC_NUMERIC=C printf '%.2f' "$cost") · ${mins}min${R}")

line2=""
for p in "${parts[@]}"; do
  [[ -n $line2 ]] && line2+="${SEP}"
  line2+="$p"
done

printf '%b\n%b\n' "$line1" "$line2"
