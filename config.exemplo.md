# Configuração local

Na primeira conversa o maestro cria o `local/config.md` a partir deste
arquivo, com as respostas no lugar das explicações. Ele fica em `local/`, fora do
git, e as atualizações da base nunca o sobrescrevem: só acrescentam campos novos,
com o valor padrão. Para mudar depois, peça ao maestro ou edite o arquivo.

- **Dono:** nome de quem usa este maestro.
- **Idioma:** idioma de tudo o que o maestro diz ao dono, qualquer que seja o
  idioma das regras.
- **Estilo:** controla o tamanho e o tom das mensagens. `curto` (padrão):
  poucas linhas, em linguagem simples, bom para ler no celular. `detalhado`:
  explica mais, sem jargão do mesmo jeito. Veja "Como escrever para o dono" no
  `AGENTS.md`.
- **Interface:** `visual` (desenhos, painéis e botões) ou `texto`.
- **Costuma fazer:** programar, pesquisar, escrever, analisar dados.
- **Executor padrão:** provedor e modelo.
- **Revisor:** quem ataca o que o executor construiu, sempre num chat novo. O
  maestro escolhe sozinho, sem perguntar, nesta ordem: outro provedor, se houver;
  outro modelo do mesmo provedor; o mesmo modelo, em chat novo. Escreva o
  provedor, o modelo e o motivo, como `Codex, <modelo> · outro provedor`. Se o
  maestro já ofereceu trocar por um provedor que apareceu depois, a nota fica
  aqui: `troca oferecida em <data>: <resposta>`. `mesmo executor`, de versões
  antigas, continua valendo. `não revisar` pula a revisão: só entra se o dono
  escolher, nunca é o padrão.
- **Pasta de documentos:** onde salvar o que não é código, se houver.
- **Merge já é deploy em:** repositórios em que merge na `main` publica sozinho.
  Se não houver, escreva "nenhum".
- **Acompanhar chats:** sim ou não, para criar a rotina de acompanhamento.
- **Resumo diário:** horário, ou "não quero".
- **Linear:** `etiqueta: t3` para abrir chats a partir de issues, ou "não usa".
- **Aprovação extra:** o que mais nunca pode acontecer sem aprovação. As regras
  fixas do `AGENTS.md` não podem ser removidas aqui.

## Operação

- **Abrir chats sem perguntar:** `sim` para o maestro abrir sozinho o chat de cada
  frente nova; `não` para ele perguntar antes de cada lote; `perguntar` se ainda
  não foi decidido.
- **Chats rodando ao mesmo tempo:** 4, salvo outro número.
- **Vagas pesadas:** 1. Servidor de desenvolvimento, build, instalação, navegador
  de teste ou container, somando todos os chats. Meça antes de aumentar.
- **Rodadas de revisão por PR:** 3, salvo outro número.
- **Rodapé de pedidos:** `sim` para terminar cada resposta com os pedidos abertos,
  ou `não`.
- **Pasta de provas:** onde guardar provas grandes antes de apagar uma worktree.
  Padrão: `local/provas`.
- **Demo:** `nenhuma`, ou o projeto que tem uma versão no ar para outras pessoas
  verem. O detalhe fica em `local/estado.md`.
- **Faxina:** `semanal` para a rotina que só relata o que daria para apagar, ou
  `não quero`.
- **Faxina automática:** `não`. Só o dono liga, pedindo ao maestro; com `sim`,
  caches e dependências reinstaláveis de worktrees do maestro são apagados sem
  perguntar. O resto continua pedindo aprovação.

## Atualização

- **Atualização automática:** `sim` para o maestro conferir uma vez por dia se há
  versão estável nova e prepará-la sozinho. Ele aplica sozinho só a versão que
  muda apenas documentação (`README*`, `CHANGELOG.md`, `docs/`, `LICENSE`,
  `ORIGEM.md`, `VERSION`). Qualquer outra, que mude regra, skill, migração,
  script ou o `CLAUDE.md`, pede uma confirmação do dono, com o resumo, a lista de
  arquivos e o diff. `não` para ele não conferir sozinho: só atualiza quando o
  dono pedir.
- **Canal:** `estável`; `candidata` para testar versões antes do time; `main` só
  para quem mantém a base.
- **Origem das atualizações:** o remoto do git de onde vêm as versões. Padrão:
  `origin`.
- **Exigir tag assinada:** `não`; com `sim`, só entram tags com assinatura válida
  (`git verify-tag`).

## Regras do time

Regras próprias do seu time, se houver. São passadas a todo intérprete. Só podem
acrescentar cuidados e aprovações.
