# dotfiles — Dirt

Desktop Linux com i3 em X11, inspirado no grunge de Seattle e na estética das tatuagens blackwork: fundos marrom-quase-preto, tinta, Gruvbox apagado. A ideia é ser escuro, sóbrio e legível.

Ferramentas: **i3 · polybar · picom · rofi · dunst · kitty · zsh · tmux**

## Filosofia

- **Legibilidade antes de efeito.** Quase sem transparência e sem blur. Contraste confortável para passar o dia no terminal.
- **Uma paleta, um raio, uma fonte.** Todas as ferramentas usam as mesmas cores (`theme/palette.sh`), o mesmo raio de canto (8px nas janelas, 4px nos itens) e a mesma fonte (JetBrainsMono Nerd Font).
- **Nada em silêncio.** O instalador é idempotente, tem `--dry-run` e faz backup antes de substituir qualquer arquivo.
- **Público por padrão.** Nenhum segredo vai para o repo. O que é só da máquina (identidade do git, funções de CLIs da empresa, tokens) fica em arquivos locais.

## Paleta "Dirt"

Fonte da verdade: [`theme/palette.sh`](theme/palette.sh). Arquivos que não leem variáveis (kitty, i3, polybar, rofi, dunst, tmux, git) repetem os valores abaixo.

| Papel | Cor | Onde aparece |
| --- | --- | --- |
| `bg0` | `#110e0b` | barra, fundo do tmux, janelas sem foco, tela de bloqueio |
| `bg` | `#1a1613` | terminal, menus, notificações |
| `bg1` | `#241e19` | campos de entrada, mensagem do usuário |
| `bg2` | `#2f2722` | item selecionado, aba ativa |
| `line` | `#3b322b` | bordas e separadores |
| `gray` | `#7c6f64` | texto secundário, sugestões do shell |
| `fg-dim` | `#a89984` | texto de apoio |
| `fg` | `#d4be98` | texto principal (off-white quente) |
| `fg-bright` | `#e6d5b3` | destaque de texto |
| `accent` | `#b8652f` | laranja Gruvbox apagado: foco, prompt, bordas ativas |
| `red` | `#8e3b3b` / `#a85050` | bordô: erro, urgente |
| `green` | `#7f8448` / `#9a9c62` | oliva: sucesso, comandos válidos |
| `yellow` | `#b08a3e` / `#c9a35a` | ocre: avisos, strings |
| `blue` | `#6f8584` / `#8a9e9b` | aço |
| `magenta` | `#8a6c75` / `#a5858f` | malva |
| `cyan` | `#6e8a6f` / `#88a389` | sálvia |

## Estrutura

```
install.sh              instalador (idempotente, --dry-run)
theme/palette.sh        paleta em variáveis shell
wallpaper/              dirt-contours.jpg e o script que o gera
i3/                     config modular (*.conf) + scripts/ (monitor, wallpaper, lock)
polybar/                config.ini + módulos em shell
rofi/                   colors.rasi + temas (launcher, menu de energia, calendário, wallpaper)
dunst/dunstrc           notificações
picom/picom.conf        compositor
kitty/kitty.conf        terminal
zsh/.zshrc, .zshenv     shell (o ~/.zshrc da máquina só carrega este arquivo)
tmux/tmux.conf          multiplexador
git/gitconfig           preferências do git, sem identidade
claude/                 Claude Code: statusline, hooks, skills, agentes, tema
aic/config.toml         config inicial do AIC
vscode/                 settings + CSS
sworkstyle/             ícones nos nomes dos workspaces (opcional)
```

## Instalação

```bash
git clone git@github.com:viniciuscg/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run    # mostra tudo o que faria
./install.sh              # instala
```

| Opção | O que faz |
| --- | --- |
| `--dry-run` | Lista cada ação sem executar nenhuma. |
| `--links` | Só configs, links, zsh, git, wallpaper, VS Code e Claude. Não instala pacotes, fontes, Oh My Zsh nem AIC. |
| `--no-packages` | Pula os pacotes do sistema, que é a única etapa que usa `sudo`. |
| `--claude` | Só a configuração do Claude Code. |

O que o instalador faz, em ordem:

1. **Pacotes.** Verifica quais faltam e pede confirmação antes de usar `sudo`. Sem terminal interativo, não instala nada.
2. **Oh My Zsh e plugins** (autosuggestions e syntax-highlighting). O instalador oficial roda com `KEEP_ZSHRC=yes`, então não mexe no seu `~/.zshrc`.
3. **Fonte.** JetBrainsMono Nerd Font, só se ainda não estiver instalada.
4. **Links.** Cada config vira um symlink para o repo. O que estiver no caminho vai para `~/.dotfiles_backup/<data>/`. Links quebrados que apontam para o repo, sobras de versões antigas, são removidos.
5. **Polybar.** O `config.ini` é copiado, não linkado, com `~` trocado pelo caminho absoluto.
6. **zsh.** O `~/.zshrc` vira um arquivo local que faz `source` do `zsh/.zshrc` do repo (detalhes abaixo).
7. **git.** Adiciona `include.path` no `~/.gitconfig`. Nome, e-mail e assinatura GPG não são tocados.
8. **Wallpaper, VS Code e Claude Code.**
9. **AIC e shell padrão.** Troca para zsh com `chsh`, que pede a sua senha.

Rodar de novo é seguro: o que já estiver certo é pulado e, no fim, aparece "tudo já estava em dia".

### Aplicar sem sair da sessão

| O quê | Como |
| --- | --- |
| i3, polybar e wallpaper | `Mod+Shift+r` |
| dunst | `killall dunst` (o dbus sobe de novo na próxima notificação) |
| kitty | `ctrl+shift+F5` em cada janela |
| tmux | `Ctrl+a` e depois `r` |
| zsh | abrir um terminal novo |

## Dependências

Instaladas pelo `install.sh` em Debian/Ubuntu, Arch e Fedora:

| Grupo | Pacotes |
| --- | --- |
| Desktop | `i3` (≥ 4.22, por causa dos gaps), `polybar`, `picom`, `rofi` (≥ 1.7), `dunst` (≥ 1.9), `feh`, `dex`, `nm-applet` |
| Terminal | `kitty`, `zsh`, `tmux` (≥ 3.2), `git`, `curl`, `jq` |
| Utilitários | `imagemagick` (wallpaper), `flameshot`, `i3lock`, `xss-lock`, `playerctl`, `brightnessctl`, `pactl` (pulseaudio-utils, funciona com PipeWire), `pavucontrol`, `yad`, `xrandr`/`xset`/`setxkbmap` |
| Fonte | JetBrainsMono Nerd Font v3.1.1 |
| Opcionais | `fzf` e `zoxide` (o zsh ativa sozinho se existirem), tema de ícones Papirus ou Yaru, `sworkstyle` (`cargo install sworkstyle`) |

O pacote `pulseaudio` **não** é instalado, só o `pactl`. Em sistemas com PipeWire, instalar o PulseAudio completo causa conflito.

## Wallpaper

`wallpaper/dirt-contours.jpg` (3840×2160, cerca de 400 KB) mostra curvas de nível orgânicas em tinta sobre fundo marrom-quase-preto, com uma única "veia" em laranja apagado. O lado esquerdo é mais calmo e o direito tem mais detalhe.

- **Licença:** gerado do zero por [`wallpaper/generate.sh`](wallpaper/generate.sh) com ImageMagick (ruído fractal → curvas de nível). Não tem arte de terceiros e pode ser considerado domínio público (CC0).
- **Gerar outra variação:** `wallpaper/generate.sh 3840 2160 saida.jpg <semente>`. A semente padrão é 1993; cada semente desenha um relevo diferente.
- **Vários monitores:** `polybar/wallpaper_lib.sh` lê o layout com `xrandr --listmonitors`, recorta a imagem para cada tela (preenchimento com corte central) e aplica um único fundo com `feh`. O `i3/scripts/monitor.sh` reaplica o fundo depois de cada mudança de layout.
- **Trocar:** pelo ícone de wallpaper na polybar (abre o seletor no rofi), ou coloque imagens em `~/.config/wallpaper/` ou `~/.local/share/walls/`. A escolha fica salva em `~/.config/polybar/.wallpaper_state`. A coleção [dharmx/walls](https://github.com/dharmx/walls) é opcional: `INSTALL_DHARMX_WALLS=1 ./install.sh`.

## Atalhos

### i3 (`Mod` = Super)

| Atalho | Ação |
| --- | --- |
| `Mod+Return` | terminal |
| `Mod+d` / `Mod+Shift+d` / `Mod+Tab` | apps / comandos / janelas abertas (rofi) |
| `Mod+j k l ;` ou setas | mover o foco (com `Shift`, move a janela) |
| `Mod+h` / `Mod+v` | dividir na horizontal / vertical |
| `Mod+f` | tela cheia |
| `Mod+s` / `Mod+w` / `Mod+e` | layout empilhado / em abas / alternar divisão |
| `Mod+Shift+space` / `Mod+space` | alternar flutuante / alternar foco entre flutuante e lado a lado |
| `Mod+1…0` | ir ao workspace (com `Shift`, move a janela) |
| `Mod+r` | modo de redimensionar |
| `Mod+F1` / `Mod+F2` | scratchpad do terminal / do Spotify |
| `Mod+Shift+x` | bloquear a tela |
| `Mod+Shift+e` | menu de energia: bloquear, sair, reiniciar, desligar |
| `Mod+Shift+c` / `Mod+Shift+r` | recarregar / reiniciar o i3 |
| `Print` / `Mod+Print` | captura da tela inteira / seleção (flameshot) |
| teclas de mídia | volume (±5%), play/pause, próxima/anterior, brilho |

### tmux (prefixo `Ctrl+a`)

| Atalho | Ação |
| --- | --- |
| `prefixo + \|` / `prefixo + -` | dividir na horizontal / vertical, no diretório atual |
| `prefixo + h j k l` | mover entre painéis |
| `prefixo + H J K L` | redimensionar o painel (repete enquanto segura) |
| `Alt+1…9` | ir para a janela N, sem prefixo |
| `prefixo + v` e depois `v` / `y` | modo cópia: selecionar / copiar (teclas do vi) |
| `prefixo + r` | recarregar a config |
| `tm` (alias do zsh) | entrar na sessão `main` ou criá-la |

### kitty

`ctrl+shift+t` aba nova · `ctrl+shift+enter` janela nova · `ctrl+shift+l` próximo layout · `ctrl+shift+h` histórico de rolagem · `ctrl+shift+a` e depois `m`/`l` ajusta a opacidade

## zsh

- O prompt é próprio, feito com `vcs_info`, sem Starship nem Powerlevel. Mostra a pasta, a branch, `●` para mudanças não staged e `+` para mudanças staged. O `❯` fica vermelho quando o último comando falha.
- O Oh My Zsh fica só pelos plugins e pelos aliases de git.
- O PATH não tem duplicatas (`typeset -U path`).
- O histórico guarda 50 mil linhas, sem duplicatas, compartilhado entre terminais.

**Por que o `~/.zshrc` não é um link:** algumas CLIs se instalam editando o `~/.zshrc` com `sed -i`, e isso transforma o symlink num arquivo comum. Por isso o `~/.zshrc` da máquina é um arquivo pequeno com uma linha que carrega o `zsh/.zshrc` do repo. Abaixo dela fica o que é só daquela máquina: funções de CLIs, exports, variáveis com segredos. Na migração, o arquivo antigo vai para o backup e o instalador avisa para copiar de lá o que for local.

## git

O `git/gitconfig` entra no `~/.gitconfig` via `[include]` e traz:

- cores da paleta;
- `diff.algorithm = histogram` e `colorMoved`;
- `fetch.prune` e `push.autoSetupRemote`;
- `rerere`;
- aliases: `st`, `lg`, `last`, `amend`, `unstage`.

Identidade, `signingkey` e `gpgsign` continuam só no `~/.gitconfig` local.

## Claude Code

A configuração fica em `claude/` e é aplicada pelo `install.sh` (ou só ela, com `./install.sh --claude`):

| Arquivo | Destino e função |
| --- | --- |
| `statusline.sh` | `~/.claude/statusline.sh`: modelo, pasta, branch, contexto, limites de 5h e da semana, custo. |
| `hooks/notify.sh` | Notificação no dunst quando o Claude pede permissão ou termina. |
| `themes/dirt.json` | Tema na paleta Dirt, ativo via `"theme": "custom:dirt"`. O antigo `minimal.json` continua disponível. |
| `CLAUDE.md`, `skills/`, `agents/` | Instruções globais, skills e subagentes. |
| `settings.json` | Mesclado em `~/.claude/settings.json`, não linkado, porque o Claude também grava nele. A versão anterior fica em `settings.json.pre-dotfiles`. |
| `bin/claude-job` + `jobs/` | Tarefas agendadas (`cjob list`, `cjob on bom-dia`). |

Guia de uso: [claude/GUIA.md](claude/GUIA.md).

## Reverter

- **Tudo que foi substituído** está em `~/.dotfiles_backup/<data>/`, com o mesmo caminho relativo ao `$HOME`. Para voltar um arquivo, apague o link e mova o backup de volta:

  ```bash
  rm ~/.config/kitty/kitty.conf
  mv ~/.dotfiles_backup/<data>/.config/kitty/kitty.conf ~/.config/kitty/
  ```

- **Voltar ao tema anterior inteiro:** `git -C ~/dotfiles log` e depois `git -C ~/dotfiles checkout <commit> -- <arquivos>`. Os links continuam apontando para o repo, então basta recarregar (veja "Aplicar sem sair da sessão").
- **git:** `git config --global --unset include.path ~/dotfiles/git/gitconfig`
- **Claude:** `cp ~/.claude/settings.json.pre-dotfiles ~/.claude/settings.json`
- **Wallpaper:** escolha outro no seletor da polybar.

## Solução de problemas

| Sintoma | Causa provável e solução |
| --- | --- |
| Ícones aparecem como quadrados | A Nerd Font não está instalada. Rode `fc-list \| grep JetBrainsMono`; se não aparecer nada, rode `./install.sh` sem `--links`. |
| A polybar não aparece | Rode `~/.config/polybar/launch.sh` num terminal e veja o erro. O `config.ini` é cópia: depois de editar o do repo, rode `./install.sh --links`. |
| O wallpaper ficou preto numa tela | Rode `xrandr --listmonitors` e depois `~/.config/i3/scripts/load_wallpaper.sh`. Sem o ImageMagick, cai no `feh --bg-fill` simples. |
| Notificações com o visual antigo | O dunst lê a config só ao iniciar: `killall dunst`. |
| tmux sem cores ou com prefixo `Ctrl+b` | Existe um `~/.tmux.conf`, que tem prioridade sobre `~/.config/tmux/tmux.conf`. Remova-o ou renomeie. |
| O terminal fica preso no `Mod+Shift+x` | O `i3lock` está esperando a sua senha. Digite e aperte Enter (a tela é a cor `bg0`, sem indicador). |
| `Mod+Shift+e` não faz nada | Falta o rofi ou o link `~/.config/rofi/powermenu.sh`. Rode `./install.sh --links`. |
| Uma CLI "quebrou" o zsh | Confira se a primeira linha do `~/.zshrc` ainda tem `# dotfiles:zshrc`. Se não tiver, rode `./install.sh --links`. |

## Limitações

- **Só X11 e i3.** Não há config para Wayland ou Sway.
- **Monitores fixos.** `i3/workspaces.conf` e `i3/scripts/monitor.sh` usam os nomes desta máquina (`eDP-1`, `DP-1-5`, `DP-1-6`). Em outro hardware, ajuste os dois.
- **Bloqueio automático desligado.** Por escolha, a tela nunca apaga nem bloqueia sozinha (`xset -dpms`, `xss-lock` comentado). Para ativar, descomente a linha em `i3/autostart_basic.conf`.
- **Sem Neovim.** Não há config de editor além do VS Code; o `EDITOR` padrão é o `vim`.
- **Validação visual.** As configs são checadas por parser (`i3 -C`, `polybar --dump`, `rofi -dump-theme`, servidor tmux isolado, `kitty` `load_config`) e o wallpaper foi inspecionado como imagem. A aparência final de cada app na tela ainda não foi conferida.
- **Capturas de tela.** As imagens em `example/` são do tema anterior e ainda não foram refeitas.
- **Dunst.** Sem um checador de config dedicado: a sintaxe é validada como INI, e erros só aparecem no log ao iniciar (`dunst -verbosity info`).

## Licença

Dotfiles pessoais: use e modifique à vontade. O wallpaper é gerado pelo próprio repo (CC0).
