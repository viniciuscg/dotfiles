#!/usr/bin/env bash
# Hook de Notification: manda um aviso pro dunst quando o Claude precisa de você
# (pedido de permissão, terminou, ou um agente em background mudou de estado).
input=$(cat)
type=$(jq -r '.notification_type // ""' <<<"$input")
msg=$(jq -r '.message // "Claude precisa de você"' <<<"$input")
dir=$(basename "$(jq -r '.cwd // ""' <<<"$input")")

snd=/usr/share/sounds/freedesktop/stereo
case $type in
  permission_prompt) urgency=critical; title="🔐 Claude pede permissão"; sound=dialog-warning ;;
  idle_prompt)       urgency=normal;   title="✅ Claude terminou";       sound=complete ;;
  agent_needs_input) urgency=critical; title="🔐 Agente em background precisa de você"; sound=dialog-warning ;;
  agent_completed)   urgency=normal;   title="✅ Agente em background terminou"; sound=complete ;;
  *)                 urgency=low;      title="🤖 Claude";                sound=message ;;
esac

notify-send -a "Claude Code" -u "$urgency" "$title${dir:+ · $dir}" "$msg" 2>/dev/null
[[ -f $snd/$sound.oga ]] && (paplay "$snd/$sound.oga" 2>/dev/null &)
exit 0
