---
name: aprender
description: Transforma o que foi feito nesta conversa em conhecimento permanente - cria ou melhora uma skill reutilizável e salva preferências na memória. Use depois de uma tarefa complexa que vai se repetir, ou quando o usuário disser "aprende isso", "salva isso", "da próxima vez faz assim".
---

Objetivo: o Claude ficar melhor a cada uso, sem o usuário repetir instruções.

1. Revise a conversa e identifique:
   - **Procedimentos repetíveis**: uma tarefa com vários passos que deu certo (ou que deu certo depois de correções).
   - **Preferências e correções do usuário**: "não faz X", "prefiro Y", formato de resposta, ferramentas preferidas.
   - **Fatos sobre o ambiente**: caminhos, contas, serviços, configurações que não dá pra deduzir olhando os arquivos.

2. Para cada procedimento repetível, crie ou atualize uma skill em `~/dotfiles/claude/skills/<nome-curto>/SKILL.md` (o `install.sh` cria o link em `~/.claude/skills/`; se o link ainda não existir, crie com `ln -s`):
   - Frontmatter com `name` e uma `description` que diga **o que faz e quando usar**, com as palavras que o usuário usaria pra pedir.
   - Corpo com os passos que funcionaram, incluindo as armadilhas encontradas. Curto e direto.
   - Se já existe skill parecida, melhore ela em vez de criar outra.

3. Preferências e fatos vão pra memória automática (não pra skill). Correções de comportamento que valem pra tudo vão pro `~/dotfiles/claude/CLAUDE.md`, só se forem gerais e curtas.

4. Mostre um resumo: o que virou skill (com o comando `/nome`), o que foi pra memória e o que mudou no CLAUDE.md. Não faça commit sem o usuário pedir.
