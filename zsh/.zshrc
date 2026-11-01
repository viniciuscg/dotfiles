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
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6a8290"
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

# 🎨 Realce de sintaxe na paleta "Yuta"
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#8fbc9a'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8fbc9a'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#8fbc9a'
ZSH_HIGHLIGHT_STYLES[function]='fg=#8fbc9a'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#8fbc9a,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#cf6b78'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#7fb3c1'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d3dade,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#d0bc8a'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#d0bc8a'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6a8290'

# ❯ Prompt próprio: rápido, sem framework.
#   ~/pasta  branch●     (● mudanças não staged, + staged)
#   ❯                    (vermelho se o último comando falhou)
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '●'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '  %F{#94a6ab}%b%F{#7fb3c1}%c%u%f'
zstyle ':vcs_info:git:*' actionformats '  %F{#94a6ab}%b%f %F{#d0bc8a}(%a)%f%F{#7fb3c1}%c%u%f'
add-zsh-hook precmd vcs_info
setopt PROMPT_SUBST
PROMPT=$'\n''%F{#d3dade}%B%~%b%f${vcs_info_msg_0_}'$'\n''%(?.%F{#7fb3c1}.%F{#cf6b78})❯%f '
RPROMPT='%(1j.%F{#6a8290}%j bg%f.)'
