# zsh — config compartilhada dos dotfiles.
#
# Não é linkada em ~/.zshrc: o ~/.zshrc da máquina é um arquivo pequeno que faz
# `source` deste aqui e guarda o que é só daquela máquina (funções de CLIs que
# se instalam editando o ~/.zshrc, por exemplo). Ver install.sh → install_zshrc.

# 📦 Oh My Zsh — só pelos plugins; o prompt é próprio (lá embaixo).
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
zstyle ':omz:update' mode reminder
DISABLE_MAGIC_FUNCTIONS=true # colar texto longo sem travar
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7c6f64"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40

# zsh-syntax-highlighting precisa ser o último
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# 🧭 PATH (sem duplicatas)
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path /usr/local/go/bin "$HOME/go/bin")

# 📜 Histórico
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY
setopt INTERACTIVE_COMMENTS NO_BEEP

# ✍️ Editor
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
export LESS="-R --mouse"

# 🔤 Aliases
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lh'
alias la='ls -lhA'
alias grep='grep --color=auto'
alias cls='clear'

# Claude Code
alias c='claude'
alias ct='claude --continue'                # continua a última conversa desta pasta
alias cr='claude --resume'                  # escolhe uma conversa antiga pra retomar
alias cplan='claude --permission-mode plan' # só planeja/pesquisa, não altera nada
alias ca='claude agents'                    # painel dos agentes em background
alias cbg='claude --bg'                     # cbg "tarefa" -> roda em background
alias crc='claude --remote-control'         # sessão controlável pelo celular (claude.ai/app)
alias cjob='claude-job'                     # tarefas agendadas: cjob list | cjob on bom-dia

# tmux: entra na sessão "main" ou cria
alias tm='tmux new-session -A -s main'

# 🔌 Ferramentas opcionais (só se estiverem instaladas)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
for f in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
  [[ -r $f ]] && source "$f" && break
done
unset f

# 🎨 Realce de sintaxe na paleta "Dirt"
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#9a9c62'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9a9c62'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#9a9c62'
ZSH_HIGHLIGHT_STYLES[function]='fg=#9a9c62'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#9a9c62,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#a85050'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#b8652f'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d4be98,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#c9a35a'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#c9a35a'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#7c6f64'

# ❯ Prompt próprio: rápido, sem framework.
#   ~/pasta  branch●     (● mudanças não staged, + staged)
#   ❯                    (vermelho se o último comando falhou)
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '●'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '  %F{#a89984}%b%F{#b8652f}%c%u%f'
zstyle ':vcs_info:git:*' actionformats '  %F{#a89984}%b%f %F{#c9a35a}(%a)%f%F{#b8652f}%c%u%f'
add-zsh-hook precmd vcs_info
setopt PROMPT_SUBST
PROMPT=$'\n''%F{#d4be98}%B%~%b%f${vcs_info_msg_0_}'$'\n''%(?.%F{#b8652f}.%F{#a85050})❯%f '
RPROMPT='%(1j.%F{#7c6f64}%j bg%f.)'
