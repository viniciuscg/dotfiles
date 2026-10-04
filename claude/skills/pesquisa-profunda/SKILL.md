---
name: pesquisa-profunda
description: Pesquisa um assunto a fundo usando vários agentes pesquisadores em paralelo, cruza as fontes e entrega um relatório com links. Use para "pesquisa sobre", "compara X e Y", "qual o melhor", "me explica a fundo", decisões de compra, viagem, estudo ou trabalho.
argument-hint: "[assunto]"
---

Assunto: $ARGUMENTS

1. Quebre o assunto em 3 a 6 perguntas que, respondidas, cobrem o tema (ex.: o que é, opções, prós e contras, preços, opiniões de usuários reais, novidades recentes).
2. Lance um subagente `pesquisador` por pergunta, **todos na mesma mensagem** pra rodarem em paralelo. Cada um recebe a pergunta, o contexto do usuário e a instrução de trazer fontes com link e data.
3. Quando voltarem, lance um subagente `verificador` com as afirmações mais importantes ou que conflitam entre si.
4. Escreva o relatório em português em `~/claude-out/pesquisa-<tema-curto>-<AAAA-MM-DD>.md`:
   - **Resposta curta** (3-5 linhas, com recomendação se couber)
   - **Detalhes** por pergunta
   - **Pontos de divergência** entre fontes
   - **Fontes** (links)
5. No chat, mostre só a resposta curta e o caminho do arquivo.
