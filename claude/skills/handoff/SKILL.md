---
name: handoff
description: Escreve um HANDOFF.md com o estado do trabalho atual pra uma conversa nova continuar de onde parou. Use antes de /clear, quando o contexto estiver cheio ou ao trocar de sessão.
disable-model-invocation: true
---

Escreva (ou atualize, se já existir) `HANDOFF.md` na pasta atual pra que uma conversa nova, sem nenhum contexto, consiga continuar o trabalho.

Se o arquivo já existir, leia antes e mantenha o que ainda vale.

Estrutura:
- **Objetivo**: o que estamos tentando fazer, em 1-2 frases.
- **Feito**: o que já está pronto e verificado.
- **Em andamento**: o que estava sendo feito agora e em que ponto parou.
- **Próximos passos**: lista ordenada e concreta.
- **Decisões e porquês**: escolhas feitas e o motivo, pra não serem refeitas.
- **Armadilhas**: o que já deu errado e não deve ser tentado de novo.
- **Arquivos e links importantes**: caminhos absolutos e URLs.

No fim, diga em uma linha: "Pronto. Rode /clear e depois: leia HANDOFF.md e continue."
