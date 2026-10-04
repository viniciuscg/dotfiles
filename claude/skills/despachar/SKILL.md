---
name: despachar
description: Divide um pedido grande em várias tarefas independentes e dispara cada uma como uma sessão do Claude em background, que roda em paralelo sem travar a conversa. Use quando o usuário pedir várias coisas de uma vez, disser "faz tudo isso em paralelo", "manda pros agentes", "despacha", ou quando um trabalho for grande e divisível.
argument-hint: "[lista de tarefas ou objetivo grande]"
---

Pedido: $ARGUMENTS

1. Quebre o pedido em tarefas **independentes** (uma não depende do resultado da outra). Se houver dependência, agrupe na mesma tarefa ou deixe a dependente pra depois.
2. Mostre a lista numerada ao usuário com um nome curto pra cada tarefa e confirme antes de disparar se forem mais de 5 tarefas ou se alguma mexer em algo fora da pasta atual.
3. Para cada tarefa, rode um comando separado:
   ```bash
   claude --bg --name "<nome-curto>" "<prompt completo e autossuficiente>"
   ```
   - O prompt precisa ter todo o contexto (a sessão nova não vê esta conversa): objetivo, pasta, arquivos, critério de pronto e onde salvar o resultado.
   - Peça pra cada sessão salvar o resultado final em `~/claude-out/<nome-curto>.md`.
4. No fim, diga:
   - quantas sessões foram disparadas e os nomes;
   - "Acompanhe com `claude agents` (ou ← numa sessão vazia). Resultados em ~/claude-out/".

Não dispare a mesma tarefa duas vezes. Cada sessão em background gasta limite/créditos como uma conversa normal: avise se forem muitas.
