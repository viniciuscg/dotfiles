# Lido por todo zsh (interativo ou não) — garante binários do usuário no PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
