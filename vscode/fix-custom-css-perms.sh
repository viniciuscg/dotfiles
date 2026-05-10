#!/usr/bin/env bash
# A mensagem "Run VS Code with admin privileges" aparece quando a extensão não consegue
# escrever em …/resources/app/out (no .deb isso é root).
#
# NÃO abras o VS Code como root — corre ISTO uma vez (usa sudo só aqui):
#   ~/dotfiles/vscode/fix-custom-css-perms.sh
#
# Snap/Flatpak: sistema só leitura → esta extensão não aplica patches; instala o .deb oficial.

set -euo pipefail

CSS="${HOME}/.config/Code/User/vscode-custom.css"
[[ -e "$CSS" ]] && chmod a+r "$CSS" 2>/dev/null || true

candidates=()

for bin in code code-insiders cursor codium; do
    p=$(command -v "$bin" 2>/dev/null) || continue
    real=$(readlink -f "$p")
    app=$(dirname "$(dirname "$real")")
    out="${app}/resources/app/out"
    [[ -d "$out" ]] && candidates+=("$out")
done

for fixed in \
    "/usr/share/code/resources/app/out" \
    "/usr/share/code-insiders/resources/app/out" \
    "/usr/lib/code/resources/app/out" \
    "/opt/visual-studio-code/resources/app/out"; do
    [[ -d "$fixed" ]] && candidates+=("$fixed")
done

mapfile -t candidates < <(printf '%s\n' "${candidates[@]}" | sort -u)

if ((${#candidates[@]} == 0)); then
    echo "Não encontrei …/resources/app/out."
    echo "Instala o VS Code pelo .deb oficial (não Snap) ou usa tarball em ~/."
    exit 1
fi

echo "Pastas que vão ficar com dono ${USER}:"
printf '  %s\n' "${candidates[@]}"
echo
echo "Isto evita ter de abrir o VS Code como administrador (o que não deve fazer)."
echo

for base in "${candidates[@]}"; do
    sudo chown -R "${USER}:${USER}" "$base"
done

echo
echo "Pronto. Fecha TODAS as janelas do VS Code, abre de novo e:"
echo "  Ctrl+Shift+P → Enable Custom CSS and JS"
echo
echo "Se atualizares o pacote \"code\" com apt, pode voltar a root — corre este script de novo."
