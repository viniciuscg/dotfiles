#!/bin/sh
# Hora/data na barra: fuso São Paulo; nomes em inglês (mês/dia).

export TZ=America/Sao_Paulo

avail=$(locale -a 2>/dev/null) || avail=""

if echo "$avail" | grep -qiE '^en_US\.(utf8|UTF-8)$'; then
  export LC_TIME=en_US.UTF-8
elif echo "$avail" | grep -qx 'C.UTF-8'; then
  export LC_TIME=C.UTF-8
else
  export LC_TIME=C
fi

date +'%I:%M %p · %a %d %b'
