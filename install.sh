#!/usr/bin/env bash
# "~/..." nas mensagens é texto para o usuário, não caminho a expandir.
# shellcheck disable=SC2088
# 🖤 Instalador dos dotfiles (i3 · polybar · kitty · zsh · tmux · rofi · dunst · picom).
#
# Idempotente: rodar de novo só ajusta o que mudou. Nunca sobrescreve em
# silêncio — tudo que estiver no caminho vai antes para ~/.dotfiles_backup/<data>/.
#
# Uso: ./install.sh [--dry-run] [--links] [--no-packages] [--claude] [--help]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
FONT_VERSION="v3.1.1"

DRY_RUN=0
LINKS_ONLY=0
SKIP_PACKAGES=0
CHANGED=0

# 🎨 Saída
if [[ -t 1 ]]; then
  C_ACC=$'\033[38;2;184;101;47m' C_DIM=$'\033[38;2;124;111;100m' C_OK=$'\033[38;2;154;156;98m'
  C_WARN=$'\033[38;2;201;163;90m' C_ERR=$'\033[38;2;168;80;80m' C_RST=$'\033[0m' C_B=$'\033[1m'
else
  C_ACC='' C_DIM='' C_OK='' C_WARN='' C_ERR='' C_RST='' C_B=''
fi
step() { printf '\n%s%s▌ %s%s\n' "$C_ACC" "$C_B" "$*" "$C_RST"; }
info() { printf '  %s%s%s\n' "$C_DIM" "$*" "$C_RST"; }
ok() { printf '  %s✓%s %s\n' "$C_OK" "$C_RST" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_WARN" "$C_RST" "$*"; }
die() {
  printf '%s✗ %s%s\n' "$C_ERR" "$*" "$C_RST" >&2
  exit 1
}

usage() {
  cat <<EOF
Uso: ./install.sh [opções]

  --dry-run      mostra o que seria feito, sem mudar nada
  --links        só configs e links (sem pacotes, fontes, Oh My Zsh e AIC)
  --no-packages  pula a instalação de pacotes do sistema (que usa sudo)
  --claude       só a configuração do Claude Code
  -h, --help     esta ajuda

Backups de qualquer arquivo substituído: ~/.dotfiles_backup/<data>/
EOF
}

# ⚙️ Execução (respeita --dry-run)
run() {
  if ((DRY_RUN)); then
    printf '  %s[dry-run]%s %s\n' "$C_WARN" "$C_RST" "$*"
  else
    "$@"
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

detect_distro() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*) echo arch ;;
    *" fedora "*) echo fedora ;;
    *" debian "* | *" ubuntu "*) echo debian ;;
    *) echo "${ID:-unknown}" ;;
    esac
  else
    echo unknown
  fi
}

# 📦 Move o que estiver em $1 para o backup, mantendo o caminho relativo ao $HOME.
backup() {
  local target=$1 rel dest
  [[ -e "$target" || -L "$target" ]] || return 0
  rel=${target#"$HOME"/}
  dest="$BACKUP_DIR/$rel"
  run mkdir -p "$(dirname "$dest")"
  run mv "$target" "$dest"
  info "backup: ~/$rel → ${dest/#$HOME/\~}"
}

# Garante um diretório real (um symlink antigo no lugar vai para o backup).
ensure_dir() {
  local d=$1
  if [[ -L "$d" ]]; then
    backup "$d"
  fi
  [[ -d "$d" ]] || run mkdir -p "$d"
}

# 🔗 Link idempotente: não faz nada se já aponta para o lugar certo.
link() {
  local src=$1 dest=$2
  [[ -e "$src" ]] || die "não existe no repo: $src"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    return 0
  fi
  ensure_dir "$(dirname "$dest")"
  backup "$dest"
  run ln -s "$src" "$dest"
  ok "link ${dest/#$HOME/\~}"
  CHANGED=1
}

# Linka cada arquivo de um padrão (sem criar links literais "*.sh" quando não casa nada).
link_glob() {
  local dest_dir=$1
  shift
  local f
  for f in "$@"; do
    [[ -e "$f" ]] || continue
    link "$f" "$dest_dir/$(basename "$f")"
  done
}

# Copia só se o destino não existir ou for diferente (com backup).
copy_file() {
  local src=$1 dest=$2
  if [[ -f "$dest" && ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
    return 0
  fi
  ensure_dir "$(dirname "$dest")"
  backup "$dest"
  run cp "$src" "$dest"
  ok "cópia ${dest/#$HOME/\~}"
  CHANGED=1
}

# Remove symlinks quebrados que apontam para dentro do repo (sobras de versões antigas).
clean_stale_links() {
  local dir l
  for dir in "$CONFIG/i3" "$CONFIG/polybar" "$CONFIG/rofi" "$CONFIG/polybar/modules"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r -d '' l; do
      [[ "$(readlink "$l")" == "$DOTFILES_DIR"/* ]] || continue
      run rm -f "$l"
      info "removido link quebrado: ${l/#$HOME/\~}"
    done < <(find "$dir" -maxdepth 1 -xtype l -print0 2>/dev/null)
  done
  # pasta de módulos antiga ficou vazia
  if [[ -d "$CONFIG/polybar/modules" ]] && [[ -z "$(ls -A "$CONFIG/polybar/modules" 2>/dev/null)" ]]; then
    run rmdir "$CONFIG/polybar/modules"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# 📦 Pacotes do sistema
# ─────────────────────────────────────────────────────────────────────────────
PKGS_DEBIAN=(i3 polybar picom rofi dunst libnotify-bin kitty zsh tmux feh imagemagick
  flameshot i3lock xss-lock dex x11-xserver-utils x11-xkb-utils playerctl brightnessctl
  pulseaudio-utils pavucontrol yad jq git curl unzip fontconfig network-manager-gnome python3)
PKGS_ARCH=(i3-wm polybar picom rofi dunst libnotify kitty zsh tmux feh imagemagick
  flameshot i3lock xss-lock dex xorg-xrandr xorg-xset xorg-setxkbmap playerctl brightnessctl
  libpulse pavucontrol yad jq git curl unzip fontconfig network-manager-applet python)
PKGS_FEDORA=(i3 polybar picom rofi dunst libnotify kitty zsh tmux feh ImageMagick
  flameshot i3lock xss-lock dex-autostart xrandr xset setxkbmap playerctl brightnessctl
  pulseaudio-utils pavucontrol yad jq git curl unzip fontconfig network-manager-applet python3)

missing_packages() {
  local distro=$1 p
  shift
  for p in "$@"; do
    case $distro in
    debian) dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "ok installed" || echo "$p" ;;
    arch) pacman -Q "$p" >/dev/null 2>&1 || echo "$p" ;;
    fedora) rpm -q "$p" >/dev/null 2>&1 || echo "$p" ;;
    esac
  done
}

install_packages() {
  step "Pacotes do sistema"
  local distro
  distro=$(detect_distro)
  local -a want=() missing=()
  case $distro in
  debian) want=("${PKGS_DEBIAN[@]}") ;;
  arch) want=("${PKGS_ARCH[@]}") ;;
  fedora) want=("${PKGS_FEDORA[@]}") ;;
  *)
    warn "distro não suportada ($distro). Instale à mão: ${PKGS_DEBIAN[*]}"
    return 0
    ;;
  esac
  mapfile -t missing < <(missing_packages "$distro" "${want[@]}")
  if ((${#missing[@]} == 0)); then
    ok "todos os ${#want[@]} pacotes já estão instalados"
    return 0
  fi
  info "faltam (${distro}): ${missing[*]}"
  if ((DRY_RUN)); then
    run sudo "<gerenciador>" install "${missing[@]}"
    return 0
  fi
  if [[ -t 0 ]]; then
    read -r -p "  Instalar com sudo agora? [s/N] " ans
    [[ "$ans" =~ ^[sSyY]$ ]] || {
      warn "pulado. Rode depois: ./install.sh"
      return 0
    }
  else
    warn "sem terminal interativo: pacotes não instalados (rode de novo num terminal)"
    return 0
  fi
  case $distro in
  debian) sudo apt-get update -qq && sudo apt-get install -y "${missing[@]}" ;;
  arch) sudo pacman -S --needed --noconfirm "${missing[@]}" ;;
  fedora) sudo dnf install -y "${missing[@]}" ;;
  esac
  ok "pacotes instalados"
}

# ─────────────────────────────────────────────────────────────────────────────
# 🐚 Oh My Zsh + plugins
# ─────────────────────────────────────────────────────────────────────────────
install_ohmyzsh() {
  step "Oh My Zsh e plugins"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh já instalado"
  else
    # KEEP_ZSHRC/CHSH/RUNZSH: o instalador oficial não mexe no ~/.zshrc nem no shell.
    run env KEEP_ZSHRC=yes CHSH=no RUNZSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" name url
  for url in https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting; do
    name=$(basename "$url")
    if [[ -d "$custom/plugins/$name" ]]; then
      ok "$name já instalado"
    else
      run git clone --quiet --depth 1 "$url" "$custom/plugins/$name"
    fi
  done
}

# ─────────────────────────────────────────────────────────────────────────────
# 🔤 Fonte (uma só: JetBrainsMono Nerd Font)
# ─────────────────────────────────────────────────────────────────────────────
install_fonts() {
  step "Fonte JetBrainsMono Nerd Font"
  if fc-list 2>/dev/null | grep -q "JetBrainsMono Nerd Font"; then
    ok "já instalada"
    return 0
  fi
  local dir="$HOME/.local/share/fonts/JetBrainsMono" tmp
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
  if ((DRY_RUN)); then
    run curl -fL "$url" "→ $dir"
    return 0
  fi
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/font.zip" "$url" && unzip -qo "$tmp/font.zip" -d "$dir"; then
    fc-cache -f "$dir" >/dev/null 2>&1 || true
    ok "instalada em ${dir/#$HOME/\~}"
  else
    warn "download falhou. Baixe em https://www.nerdfonts.com/font-downloads"
  fi
  rm -rf -- "$tmp"
}

# ─────────────────────────────────────────────────────────────────────────────
# 🔗 Configs
# ─────────────────────────────────────────────────────────────────────────────
install_links() {
  step "Configs (links para o repo)"
  clean_stale_links

  link "$DOTFILES_DIR/i3/config" "$CONFIG/i3/config"
  link_glob "$CONFIG/i3" "$DOTFILES_DIR"/i3/*.conf
  link_glob "$CONFIG/i3/scripts" "$DOTFILES_DIR"/i3/scripts/*.sh

  link_glob "$CONFIG/polybar" "$DOTFILES_DIR"/polybar/*.sh
  link "$DOTFILES_DIR/picom/picom.conf" "$CONFIG/picom/picom.conf"
  link "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG/kitty/kitty.conf"
  link "$DOTFILES_DIR/dunst/dunstrc" "$CONFIG/dunst/dunstrc"
  link "$DOTFILES_DIR/sworkstyle/config.toml" "$CONFIG/sworkstyle/config.toml"
  link_glob "$CONFIG/rofi" "$DOTFILES_DIR"/rofi/*.rasi "$DOTFILES_DIR"/rofi/*.sh
  link "$DOTFILES_DIR/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
  link "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
  link "$DOTFILES_DIR/vscode/vscode-custom.css" "$CONFIG/Code/User/vscode-custom.css"

  ((DRY_RUN)) || chmod +x "$DOTFILES_DIR"/i3/scripts/*.sh "$DOTFILES_DIR"/polybar/*.sh "$DOTFILES_DIR"/rofi/*.sh "$DOTFILES_DIR"/wallpaper/generate.sh
}

# polybar: config.ini é cópia (não link) porque troca ~ por caminho absoluto —
# o exec dos módulos custom não expande ~ em todas as versões.
install_polybar_config() {
  step "Polybar"
  local tmp dest="$CONFIG/polybar/config.ini"
  tmp=$(mktemp)
  sed "s|~/.config|$CONFIG|g" "$DOTFILES_DIR/polybar/config.ini" >"$tmp"
  copy_file "$tmp" "$dest"
  rm -f "$tmp"
}

# ~/.zshrc é um arquivo local que carrega o do repo. Assim CLIs que editam o
# ~/.zshrc com sed -i (quebrando symlinks) continuam funcionando, e o que é só
# desta máquina não vai pro repo público.
install_zshrc() {
  step "zsh"
  local rc="$HOME/.zshrc" marker="# dotfiles:zshrc"
  local line="[[ -r \"$DOTFILES_DIR/zsh/.zshrc\" ]] && source \"$DOTFILES_DIR/zsh/.zshrc\" $marker"
  if [[ -f "$rc" && ! -L "$rc" ]] && grep -qF "$marker" "$rc"; then
    ok "~/.zshrc já carrega o do repo"
    return 0
  fi
  local old=""
  if [[ -L "$rc" ]]; then
    backup "$rc"
  elif [[ -f "$rc" ]]; then
    old="$BACKUP_DIR/.zshrc"
    backup "$rc"
  fi
  if ((DRY_RUN)); then
    run "escrever ~/.zshrc local (source do repo + seção da máquina)"
    return 0
  fi
  cat >"$rc" <<EOF
# ~/.zshrc local — NÃO versionado. A config compartilhada vem do repo:
$line

# ── Só desta máquina (CLIs que se instalam aqui, PATHs locais, segredos via env) ──
EOF
  ok "~/.zshrc local criado"
  if [[ -n "$old" ]]; then
    warn "o ~/.zshrc anterior está em ${old/#$HOME/\~}"
    warn "copie de lá o que for só desta máquina (funções de CLIs, exports) para o fim do ~/.zshrc"
  fi
  CHANGED=1
}

install_tmux_legacy_note() {
  if [[ -f "$HOME/.tmux.conf" ]]; then
    warn "~/.tmux.conf existe e tem prioridade sobre ~/.config/tmux/tmux.conf — avalie removê-lo"
  fi
}

# git: inclui as preferências do repo sem tocar em nome, e-mail ou assinatura.
install_git() {
  step "git"
  local inc="$DOTFILES_DIR/git/gitconfig"
  if git config --global --get-all include.path 2>/dev/null | grep -qxF "$inc"; then
    ok "~/.gitconfig já inclui git/gitconfig"
  else
    run git config --global --add include.path "$inc"
    ok "include adicionado ao ~/.gitconfig (identidade e assinatura continuam locais)"
  fi
}

# 🖼️ Wallpaper padrão (gerado por wallpaper/generate.sh) + escolha atual preservada.
install_wallpaper() {
  step "Wallpaper"
  copy_file "$DOTFILES_DIR/wallpaper/dirt-contours.jpg" "$CONFIG/wallpaper/dirt-contours.jpg"
  local state="$CONFIG/polybar/.wallpaper_state"
  if [[ -f "$state" ]]; then
    info "escolha atual mantida ($(sed 's/.*"path": *"\([^"]*\)".*/\1/' "$state" | sed "s|$HOME|~|"))"
    info "para usar o novo: clique no ícone de wallpaper da polybar ou apague $state"
  else
    ok "dirt-contours.jpg será o fundo padrão"
  fi
}

optional_clone_dharmx_walls() {
  local dest="$HOME/.local/share/walls"
  [[ -d "$dest/.git" ]] && return 0
  [[ "${INSTALL_DHARMX_WALLS:-0}" == "1" ]] || return 0
  step "Coleção dharmx/walls (opcional)"
  run git clone --depth 1 https://github.com/dharmx/walls.git "$dest"
}

install_vscode_user_settings() {
  local repo="$DOTFILES_DIR/vscode/settings.json"
  local dest="$CONFIG/Code/User/settings.json"
  [[ -f "$repo" ]] || return 0
  step "VS Code"
  if ((DRY_RUN)); then
    run "gerar $dest a partir de vscode/settings.json"
    return 0
  fi
  local tmp
  tmp=$(mktemp)
  INSTALL_CSS="$CONFIG/Code/User/vscode-custom.css" python3 - "$repo" "$tmp" <<'PY'
import json, os, re, sys
from pathlib import Path

repo, out = Path(sys.argv[1]), Path(sys.argv[2])
text = "\n".join(l for l in repo.read_text(encoding="utf-8").splitlines() if not re.match(r"^\s*//", l))
data = json.loads(re.sub(r",(\s*[\]}])", r"\1", text))
data["vscode_custom_css.imports"] = [Path(os.environ["INSTALL_CSS"]).resolve().as_uri()]
out.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY
  copy_file "$tmp" "$dest"
  rm -f "$tmp"
}

# 🤖 Claude Code: status line, hooks, skills, agentes e CLAUDE.md global.
setup_claude_config() {
  step "Claude Code"
  local dest="$HOME/.claude" f
  link "$DOTFILES_DIR/claude/statusline.sh" "$dest/statusline.sh"
  link "$DOTFILES_DIR/claude/hooks/notify.sh" "$dest/hooks/notify.sh"
  link "$DOTFILES_DIR/claude/CLAUDE.md" "$dest/CLAUDE.md"
  link_glob "$dest/themes" "$DOTFILES_DIR"/claude/themes/*.json
  link_glob "$dest/agents" "$DOTFILES_DIR"/claude/agents/*.md
  for f in "$DOTFILES_DIR"/claude/skills/*/; do
    link "${f%/}" "$dest/skills/$(basename "$f")"
  done
  link "$DOTFILES_DIR/claude/bin/claude-job" "$HOME/.local/bin/claude-job"
  ((DRY_RUN)) || mkdir -p "$HOME/claude-out"
  # settings.json é mesclado (não link): o Claude Code também grava nele.
  local settings="$dest/settings.json" tmp
  if ((DRY_RUN)); then
    run "mesclar claude/settings.json em $settings (jq)"
    return 0
  fi
  have jq || {
    warn "jq não encontrado: settings.json do Claude não mesclado"
    return 0
  }
  [[ -f "$settings" ]] || echo '{}' >"$settings"
  tmp=$(mktemp)
  jq -s '.[0] * .[1]' "$settings" "$DOTFILES_DIR/claude/settings.json" >"$tmp"
  if cmp -s "$tmp" "$settings"; then
    rm -f "$tmp"
    ok "settings.json em dia"
  else
    cp "$settings" "$settings.pre-dotfiles"
    mv "$tmp" "$settings"
    ok "settings.json mesclado (anterior em settings.json.pre-dotfiles)"
  fi
}

install_claude_code() {
  step "Claude Code (binário)"
  if have claude || [[ -x "$HOME/.local/bin/claude" ]]; then
    ok "já instalado (atualiza sozinho)"
    return 0
  fi
  run sh -c "curl -fsSL https://claude.ai/install.sh | bash" || warn "falhou: curl -fsSL https://claude.ai/install.sh | bash"
}

# AIC — central de sessões do Claude Code (github.com/viniciuscg/AIC)
install_aic() {
  step "AIC"
  local aic_dir="$HOME/AIC"
  if [[ -d "$aic_dir/.git" ]]; then
    run git -C "$aic_dir" pull --ff-only || warn "git pull falhou em ~/AIC (mudanças locais?)"
  else
    run git clone git@github.com:viniciuscg/AIC.git "$aic_dir" || {
      warn "clone falhou (chave SSH no GitHub?). Manual: git clone git@github.com:viniciuscg/AIC.git ~/AIC"
      return 0
    }
  fi
  # config.toml copiado só se não existir: o AIC grava nele pelas Configurações.
  [[ -f "$CONFIG/aic/config.toml" ]] || copy_file "$DOTFILES_DIR/aic/config.toml" "$CONFIG/aic/config.toml"
  run "$aic_dir/install.sh" || warn "~/AIC/install.sh falhou; rode à mão"
}

change_shell() {
  [[ "$(basename "${SHELL:-}")" == "zsh" ]] && return 0
  have zsh || return 0
  step "Shell padrão"
  if [[ -t 0 ]] && ((!DRY_RUN)); then
    info "a senha pedida é a do seu usuário"
    chsh -s "$(command -v zsh)" || warn "falhou. Manual: chsh -s $(command -v zsh)"
  else
    warn "rode: chsh -s $(command -v zsh)"
  fi
}

summary() {
  step "Pronto"
  if [[ -d "$BACKUP_DIR" ]]; then
    info "backups em ${BACKUP_DIR/#$HOME/\~}"
  fi
  if ((DRY_RUN)); then
    info "nada foi alterado (--dry-run)"
    return 0
  fi
  if ((CHANGED)); then
    info "aplicar sem sair da sessão:"
    info "  i3 + polybar + wallpaper  →  Mod+Shift+r"
    info "  dunst                     →  killall dunst (o dbus sobe de novo)"
    info "  kitty                     →  ctrl+shift+F5 em cada janela"
    info "  tmux                      →  prefixo (Ctrl+a) + r"
  else
    ok "tudo já estava em dia"
  fi
}

main() {
  local only_claude=0
  while (($#)); do
    case $1 in
    --dry-run) DRY_RUN=1 ;;
    --links) LINKS_ONLY=1 ;;
    --no-packages) SKIP_PACKAGES=1 ;;
    --claude) only_claude=1 ;;
    -h | --help)
      usage
      return 0
      ;;
    *) die "opção desconhecida: $1 (veja --help)" ;;
    esac
    shift
  done

  ((EUID != 0)) || die "não rode como root (o script pede sudo só quando precisa)"

  if ((only_claude)); then
    setup_claude_config
    summary
    return 0
  fi

  printf '%s%s dotfiles%s %s%s%s\n' "$C_ACC" "$C_B" "$C_RST" "$C_DIM" "$DOTFILES_DIR" "$C_RST"
  ((DRY_RUN)) && warn "modo --dry-run: nada será alterado"

  if ((!LINKS_ONLY)); then
    ((SKIP_PACKAGES)) || install_packages
    install_ohmyzsh
    install_fonts
    install_claude_code
  fi

  install_links
  install_polybar_config
  install_zshrc
  install_tmux_legacy_note
  install_git
  install_wallpaper
  install_vscode_user_settings
  setup_claude_config

  if ((!LINKS_ONLY)); then
    optional_clone_dharmx_walls
    install_aic
    change_shell
  fi

  summary
}

main "$@"
