# Primeira conversa

Use quando `scripts/maestro.sh atualizar --auto` disser `novo-usuario`: não há
`local/config.md` nem o `config.local.md` antigo. Quem já usa o maestro não passa
por aqui; a atualização cuida dele.

## Perguntar

Antes, chame `orchestrator_capabilities` e `t3_project_list`, para só oferecer o
que existe nesta máquina.

A primeira pergunta é o idioma. Ela pode vir em inglês e em português ao mesmo
tempo, e também no idioma da primeira mensagem da pessoa, se for outro:

> Which language would you like me to use? / Em que idioma prefere conversar?

Dali em diante, tudo sai só no idioma escolhido: as outras perguntas, o resumo do
que ficou combinado e cada resposta depois. As perguntas abaixo estão em
português; faça o equivalente. Em linguagem simples e sem jargão, pergunte:

1. Como a pessoa se chama e se prefere mensagens curtas ou detalhadas.
2. Se prefere ver desenhos, painéis e botões (`visual`) ou só texto (`texto`).
3. O que costuma fazer aqui: programar, pesquisar, escrever, analisar dados. Se
   produzir documentos, em que pasta guardá-los.
4. Qual executor usar por padrão, entre os disponíveis. Se só houver um, não
   pergunte: diga qual será. Quem revisa não se pergunta; veja "Escolher o
   revisor".
5. Se você pode abrir chats sozinho quando ela pedir algo novo e independente.
   Recomende `sim`; com `não`, você pergunta antes de cada lote.
6. O que nunca pode acontecer sem aprovação, além das regras fixas.
7. Se quer os chats acompanhados de tempos em tempos, resumo diário (em que
   horário) e a faxina semanal, que só relata.

Só para quem programa, pergunte depois: em quais repositórios merge já publica, se
quer abrir chats a partir do Linear e se mantém uma demo no ar para outras pessoas.
Se os repositórios têm CI, você não pergunta: confere sozinho ao abrir cada chat de
código e só pergunta quando não achar, como em `paralelo.md`, "Com CI".

Não pergunte o que tem padrão bom: revisor, orçamento, rodadas de revisão,
rodapé, atualização automática e faxina automática ficam no padrão de
`config.exemplo.md`.

## Escolher o revisor

Não pergunte ao dono como configurar a revisão. Com a resposta de
`orchestrator_capabilities`, escolha o primeiro que existir:

1. **Outro provedor**, com o modelo mais capaz que ele oferecer. Por exemplo,
   Claude constrói e Codex revisa. É a prova mais forte.
2. **Outro modelo do mesmo provedor**, o mais capaz entre os outros.
3. **O mesmo modelo, em chat novo.**

Nos três, a revisão acontece num chat novo, que não vê a conversa de quem
construiu, e segue o roteiro de ataque (`blast-radius.md` e `interrogate.md`).
Nos casos 2 e 3, o revisor tem a mesma origem de quem construiu e tende a
concordar com ele. Para compensar, cada achado precisa de um reprodutor, e o
próprio revisor roda os testes e copia a saída. Está em `AGENTS.md`, "Revisor do
mesmo provedor".

`não revisar` nunca é o padrão: só entra se o dono pedir.

Diga ao dono, em uma ou duas frases, qual ficou e por quê, e que ele pode trocar
quando quiser. Por exemplo:

- "Quem revisa é o Codex. Outro provedor ataca melhor o que o Claude construiu."
- "Aqui só há o Claude. Quem revisa é outro modelo do Claude, num chat novo. A
  prova é mais fraca que a de outro provedor; por isso cada achado vem com um
  teste que reproduz o problema."
- "Aqui só há um modelo. Quem revisa é ele mesmo, num chat novo, sem ver a
  conversa de quem construiu. É a prova mais fraca das três; por isso cada
  achado vem com um teste que reproduz o problema, e o revisor roda os testes ele
  mesmo."

Se depois aparecer outro provedor, o maestro oferece a troca uma vez, como em
`AGENTS.md`, "Revisor do mesmo provedor".

## Criar

1. Rode `scripts/maestro.sh iniciar`. Ele cria `local/`, o índice vazio e
   `local/versao.md`, sem sobrescrever nada.
2. Registre este chat como titular: no topo de `local/estado.md`, a linha
   `Titular: <threadId> · desde <data e hora>`, com o `parentThreadId` de
   `orchestrator_capabilities`. Leia o `AGENTS.md` inteiro e o `VERSION` e
   escreva logo abaixo `Regras carregadas: v<VERSION>, relidas em <data e hora>`.
3. Crie `local/config.md` a partir de `config.exemplo.md`, com as respostas no
   lugar das explicações. "Idioma" recebe o idioma escolhido. "Abrir chats sem
   perguntar" recebe a resposta da pergunta 5, sem inventar. "Revisor" recebe o
   provedor, o modelo e o motivo da escolha, como `Codex, <modelo> · outro
   provedor`, `Claude, <modelo> · mesmo provedor, outro modelo: só havia
   Claude` ou `Claude, <modelo> · mesmo modelo, chat novo: só havia um modelo`.
4. Crie as rotinas abaixo, conforme as respostas. A `T3 Atualização` é sempre
   criada.
5. Mostre em poucas linhas o que ficou combinado, com o revisor escolhido e o
   motivo, como em "Escolher o revisor". Diga que tudo muda pedindo aqui e que
   este é o chat dele para as próximas semanas: não precisa abrir outro.
   Diga também que uma vez por dia você confere se há versão nova; que só
   documentação entra sozinha; que qualquer outra mudança, de regra ou de
   código, espera um ok dele, com o resumo e a lista de arquivos; e que basta
   dizer "não atualize sozinho" para desligar.

Para quem programa, recomende uma vez ligar a limpeza de worktrees do T3, mas só
depois que nenhuma demo morar em worktree de chat (veja `recursos.md`).

## Rotinas

Use `schedule_task` com `bindToCurrentThread: true`, depois de
`list_scheduled_tasks`, para não duplicar. Toda rotina fica presa a este chat, o
titular. Os nomes e os textos de `prompt` são fixos: rotinas antigas continuam
funcionando depois de cada atualização.

- `T3 Atualização`, sempre, todo dia:
  `{ "type": "fixed_time", "timeOfDay": "08:00" }`, sem `weekdays`, com o
  `prompt` `Atualização diária: siga a seção "Atualizar o maestro" do AGENTS.md.`
  É ela que confere as versões novas sem depender de chat novo. Quem já usa o
  maestro ganha esta rotina pela atualização, com o mesmo nome, horário e
  `prompt`.
- `T3 Monitor`, se ele quiser os chats acompanhados, com `enabled: false` até
  haver chat em andamento: `{ "type": "interval", "everyMs": 1800000 }`, com o
  `prompt` `Rotina de monitoramento: siga a seção "Rotina" do AGENTS.md.`
- `T3 Resumo`, se ele quiser, no horário do config:
  `{ "type": "fixed_time", "timeOfDay": "<hora>", "weekdays": [1, 2, 3, 4, 5] }`,
  com o `prompt` `Resumo diário: siga a seção "Resumo diário" do AGENTS.md.`
- `T3 Faxina`, se ele quiser, só relatório:
  `{ "type": "fixed_time", "timeOfDay": "09:00", "weekdays": [1] }`, com o
  `prompt` `Faxina: siga a seção "Faxina" do AGENTS.md.`
- `T3 Entrada`, só se o config indicar uma etiqueta do Linear:
  `{ "type": "fixed_time", "timeOfDay": "09:00", "weekdays": [1, 2, 3, 4, 5] }`,
  com o `prompt` `Entrada pelo Linear: siga a seção "Entrada pelo Linear" do AGENTS.md.`

Registre o ID de cada rotina na seção "Rotinas" de `local/estado.md`.
