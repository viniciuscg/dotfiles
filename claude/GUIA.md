# Guia: Claude Code no talo

Cola rápida do que está configurado nesta pasta e de como usar.

## Atalhos do terminal

| Comando | O que faz |
| - | - |
| `c` | abre o Claude |
| `ct` | continua a última conversa desta pasta |
| `cr` | escolhe uma conversa antiga |
| `cplan` | modo plano: pesquisa e planeja sem alterar nada |
| `cbg "tarefa"` | dispara uma tarefa em background e devolve o terminal |
| `ca` | painel dos agentes em background (`claude agents`) |
| `crc` | sessão que você controla pelo celular (app Claude ou claude.ai/code) |
| `cjob` | tarefas agendadas (ver abaixo) |

## Dentro do Claude

| Comando / tecla | O que faz |
| - | - |
| `/despachar <várias tarefas>` | quebra o pedido e dispara uma sessão em background por tarefa |
| `/pesquisa-profunda <assunto>` | vários pesquisadores em paralelo + verificação, relatório em `~/claude-out/` |
| `/aprender` | transforma o que foi feito em skill reutilizável + memória |
| `/handoff` | salva o estado em `HANDOFF.md` antes de um `/clear` |
| `/bg` ou `←` (prompt vazio) | manda a conversa atual pro background |
| `/tasks` | o que está rodando em background nesta sessão |
| `/loop 30m <tarefa>` | repete uma tarefa enquanto a sessão estiver aberta |
| `/schedule` | tarefa agendada na nuvem (roda com o PC desligado, precisa de Pro/Max) |
| `/remote-control` | libera esta sessão pra continuar no celular |
| `/usage` | limites de 5h e semanal |
| `/clear` / `/compact` | conversa limpa / resume a conversa |
| `/memory` | vê e edita a memória automática |
| `Shift+Tab` | troca modo de permissão (normal → auto → plano) |
| `Ctrl+O` | mostra o raciocínio |
| `Esc` / `Esc Esc` | para o Claude / volta pra uma mensagem anterior |

## Status line

```
Modelo · effort   pasta   branch ±alterações  󰧑 contexto usado
󱑂 limite 5h + quando reseta   󰃭 limite semanal   󰄦 custo · duração
```
As barras de limite só aparecem logado com assinatura Pro/Max (`/login`). Com cobrança por API aparece só o custo.

## Agentes em paralelo

- **Subagentes** (`pesquisador`, `verificador` em `agents/`): o Claude delega dentro da mesma conversa e recebe só o resumo. Rodam em paralelo.
- **Sessões em background** (`cbg`, `/despachar`, `/bg`): conversas inteiras rodando sozinhas. Acompanhe em `ca`. Notificação no dunst quando terminam ou precisam de você.
- **Agent teams** (ligado via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`): o Claude monta um time com líder e membros que conversam entre si. Experimental.

Tudo isso multiplica o consumo: 5 agentes em paralelo gastam ~5x mais rápido.

## Tarefas agendadas (estilo cron do Hermes)

Cada arquivo em `jobs/` é um prompt. A 1ª linha diz quando roda (formato `OnCalendar` do systemd):

```markdown
<!-- quando: Mon..Fri *-*-* 08:30 -->
Monte meu briefing do dia...
```

```bash
cjob list            # lista jobs e se estão ligados
cjob bom-dia         # roda agora
cjob on bom-dia      # liga o agendamento
cjob off bom-dia     # desliga
```

Resultado em `~/claude-out/jobs/` + notificação. Cada execução tem teto de US$ 2 (`CLAUDE_JOB_BUDGET`). Os jobs rodam em modo auto: ações arriscadas são bloqueadas, não perguntadas.

## Celular e mensageiros

- **Remote Control** (`crc` ou `/remote-control`): continua a sessão do PC pelo app Claude. Precisa de login claude.ai.
- **Telegram** (research preview): fale com o Claude por um bot.
  1. No Telegram, crie um bot com o @BotFather e copie o token.
  2. No Claude: `/plugin install telegram@claude-plugins-official` e `/telegram:configure <token>`.
  3. Rode `claude --channels plugin:telegram@claude-plugins-official`, mande uma mensagem pro bot e pareie com `/telegram:access pair <código>`.
  4. Trave pra só você: `/telegram:access policy allowlist`.

## Memória e aprendizado

- `CLAUDE.md`: regras fixas (curtas e específicas funcionam melhor).
- Memória automática: o Claude anota sozinho preferências e fatos (`/memory` pra ver).
- Skills: procedimentos reutilizáveis em `skills/`. Use `/aprender` depois de algo que vai se repetir.

## Onde mexer

| Quero mudar... | Arquivo |
| - | - |
| cores | `themes/minimal.json` (recarrega sozinho) |
| barra de baixo | `statusline.sh` |
| comportamento geral | `CLAUDE.md` |
| configurações | `settings.json` e depois `./install.sh --claude` |
| notificações | `hooks/notify.sh` |
