# Ferramentas do T3: o que cada uma faz e quando usar

Consulte antes de dizer que algo não dá para fazer no T3, ou ao precisar de uma
ferramenta que não usa todo dia. Vêm do servidor `t3-code`; carregue o esquema
antes de chamar. Este guia não afrouxa nada: `AGENTS.md` vale sobre ele.

🔒 = apaga, desliga, para ou muda configuração: só com o dono aprovando aquela
ação, salvo o que `AGENTS.md` já autoriza (anotado na linha). Fora disso, nunca
chame algo que crie, altere ou apague só para testar.

## Chats

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `t3_thread_launch` | Cria um chat novo, visível, com worktree, modelo e tarefa. É o jeito de abrir cada frente. |
| `create_threads` | Cria vários chats de uma vez neste mesmo checkout (herda projeto e branch). Só se o dono pedir chats lado a lado aqui; frente com worktree própria é `t3_thread_launch`. |
| `t3_thread_send` | Manda mensagem a um chat: `auto`, `queue`, `steer`; `restart` interrompe e recomeça: 🔒 só a pedido do dono. Ordens e decisões do dono. |
| `t3_thread_send_attachments` | Manda anexos já enviados (ver Anexos) como mensagem nova. Sem chave de repetição: não reenvie à toa. |
| `t3_thread_read` | Lê um chat (`messages` ou `activity`), com `limit` e `maxCharsPerItem` baixos. Antes de responder sobre ele. |
| `t3_thread_list` | Lista chats por projeto, estado, assentados ou adiados. Achar chats de uma frente. |
| `t3_thread_search` | Busca chats ativos por título, branch, PR ou texto. Não é exaustiva. |
| `t3_thread_wait` | Espera a execução de um chat terminar. Raro: os intérpretes avisam sozinhos. Nunca para vigiar em laço. |
| `t3_thread_interrupt` | 🔒 Só a pedido do dono. Interrompe a execução de um chat de topo (`stop` para parar). Para filho de `delegate_task`, é `task_cancel`. |
| `t3_thread_organize` | Fixar, adiar, assentar, arquivar, marcar não lido. `settle` e `unsettle` como em "Tudo volta para cá"; `archive` 🔒: sem pedido na hora só no passo 3 de "Encerrar um chat", depois do recibo; fora disso, só a pedido do dono. |
| `t3_thread_configure` | Lê ou troca provedor e modelo de um chat. Ler é livre; trocar 🔒, nunca por conta própria. |
| `t3_thread_update` | Renomeia um chat ou regenera o título. Para o dono reconhecer a frente. |
| `t3_thread_transfer` | `fork` copia o contexto para um chat novo; `merge_back` junta num chat relacionado **do mesmo projeto**; `status` mostra transferências. Só a pedido do dono. |
| `t3_pending_request` | Lista, lê e responde perguntas pendentes de um chat. Não aprova permissão: isso só no próprio chat. |
| `t3_queue` | Mensagens na fila de um chat: listar, ler, editar, reordenar, mandar já como `steer`; `cancel` 🔒 só a pedido do dono. |

## Tarefas dentro deste chat

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `orchestrator_capabilities` | Provedores, modelos e opções disponíveis; o `parentThreadId` é o deste chat. "Ao começar" e antes de escolher modelo. |
| `delegate_task` | Filho sem histórico, que nasce **dentro** deste chat. Nunca para abrir frente (o dono não o vê). Sobra: tarefa curta, de leitura ou conferência, no projeto deste chat, cujo resultado o maestro repassa ao dono. |
| `task_status` | Lê o resultado de um `delegate_task`. Só depois do aviso de término; não consulte em laço. |
| `task_cancel` | 🔒 Só a pedido do dono. Para um `delegate_task`: a execução, a fila, os filhos dele e as vigias de PR dele. |
| `t3_background_wait` | Mantém este chat "trabalhando" enquanto um comando em segundo plano roda. Não para servidor deixado ligado. Só Claude. |
| `t3_workflow_stop` | 🔒 Só a pedido do dono. Para um workflow do Claude dentro de um chat (o chat continua). |

## Rotinas

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `schedule_task` | Cria ou altera rotina: intervalo, horário, uma vez ou webhook. `enabled: false` pausa (🔒, salvo a `T3 Monitor` pausada pela própria rotina). Sempre depois de `list_scheduled_tasks`. |
| `list_scheduled_tasks` | Lista as rotinas e seus ids. Dentro de uma rotina, não use para se achar. |
| `delete_scheduled_task` | 🔒 Só a pedido do dono. Apaga uma rotina na hora; para só pausar, `schedule_task`. Na troca de titular, o ok dele para assumir já cobre. |
| `run_scheduled_task_now` | Roda uma rotina agora. "Começou" não é "terminou". Só a pedido do dono. |

## Projetos e worktrees

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `t3_project_list` | Lista projetos. Achar o `projectId` antes de abrir chat. |
| `t3_project_read` | Lê um projeto: pasta e scripts salvos. |
| `t3_project_create` | Registra uma pasta como projeto; sem pasta, cria repositório novo. Só a pedido do dono. |
| `t3_project_clone` | Clona um repositório numa pasta nova ou vazia; depois registre com `t3_project_create`. Só a pedido do dono. |
| `t3_project_update` | 🔒 Só a pedido do dono. Muda ajustes do projeto (nome, modelo padrão, scripts, arquivar). |
| `t3_project_delete` | 🔒 Só a pedido do dono. Apaga o projeto do T3 (`force` se tiver chats); a pasta fica no disco. |
| `t3_worktree_list` | Branches e checkouts do espaço de um chat. Conferir onde algo está. |
| `t3_worktree_status` | Worktree deste chat: caminho, branch, raiz. |
| `t3_worktree_handoff` | Move **este** chat para uma worktree nova e encerra a sessão. O maestro não usa em si; frente nova é `t3_thread_launch`. |

## Outras máquinas

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `t3_environment_links` | Máquinas ligadas e se respondem. Passe o `environmentId` às outras ferramentas para agir lá. |
| `t3_environment_link` | Mostra ao dono um cartão para ligar uma máquina que ele nomeou ("minha vps"). Nunca peça código de pareamento no chat; não chame de novo para conferir. |
| `t3_environment_read` | Identidade e preferências desta máquina (ou de outra). |
| `t3_environment_unlink` | 🔒 Só a pedido do dono. Esquece uma máquina ligada. |
| `t3_environment_preferences_update` | 🔒 Só a pedido do dono. Muda preferências da máquina inteira (modo de chat novo, estilo de commit, atividade em segundo plano). |

## PRs

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `watch_pull_request` | Vigia um PR aberto e acorda o maestro em CI, comentário ou conflito. Só o maestro; acordar não é aprovar merge. |
| `unwatch_pull_request` | Para de vigiar (o PR continua ligado). Ao encerrar o chat ou trocar de titular. |
| `link_pull_request` · `link_pull_requests` | Liga um ou vários PRs a um chat; o T3 mostra o estado e assenta no merge. |
| `unlink_pull_request` · `unlink_pull_requests` | 🔒 Só a pedido do dono. Desliga PRs de um chat (um, ou todos num estado). |
| `list_thread_pull_requests` | PRs ligados a um chat, com estado. Só quando precisar da lista. |
| `read_pull_request_guide` | Lê o guia de revisão guardado de um PR. Não inicia nada. |
| `write_pull_request_guides` | Gera guias de revisão (aba PR Guide) para até 20 PRs; leva minutos. Só a pedido do dono. |

## Navegador (preview)

Só quando o pedido atual for trabalho de navegador, ou o dono pedir para ver o
localhost. Nunca para conferir sozinho uma mudança. Feche a aba ao terminar.

| Ferramenta | O que faz |
|---|---|
| `preview_open` | Abre uma aba; para servidor local, `target` `environment-port`. |
| `preview_navigate` | Leva a aba a outro endereço ou porta. |
| `preview_act` | Clica, digita, rola, escolhe, arrasta, envia arquivo. |
| `preview_wait_for` | Espera um texto, elemento ou endereço aparecer. |
| `preview_snapshot` | Estado e elementos da página; `save` grava print para mostrar. |
| `preview_recording_start` · `preview_recording_stop` | Grava vídeo da aba; o fim devolve o arquivo. Prova de tela, só com dados fictícios. |
| `preview_evaluate` | Roda JavaScript na página; pode mudar o estado dela. Só leitura de dados. |
| `preview_dialog` | Aceita ou recusa um diálogo da página. |
| `preview_resize` | Muda o tamanho da aba (ex.: celular). |
| `preview_set_appearance` | Força tema claro ou escuro. |
| `preview_status` | Abas, dono da aba, diálogo pendente, perfis de login. |
| `t3_preview_list` | Abas deste chat; só `runtime: server` dá para automatizar. |
| `t3_preview_close` | Fecha uma aba que este chat abriu. |

## Mostrar na conversa

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `html_preview` | Confere uma página HTML antes de mostrar (imagem, altura, console). |
| `html_render` | Mostra a página aqui, acima da resposta: painel, explicação, gráfico. |

## Simulador

Só quando a tarefa precisar de simulador iOS ou emulador Android; normalmente é o
intérprete quem usa. Toque e texto vão pelo comando `agent-device` que
`device_open` devolve, nunca por `simctl` ou `adb`.

| Ferramenta | O que faz |
|---|---|
| `device_list` | Lista simuladores e emuladores de cada máquina. |
| `device_open` | Liga o aparelho, mostra no painel e devolve o comando. |
| `device_screenshot` | Print da tela do aparelho. |
| `device_close` | Tira do painel; `shutdown` também desliga o aparelho: 🔒 só a pedido do dono. |

## Segredos e anexos

| Ferramenta | O que faz · quando o maestro usa |
|---|---|
| `request_secret` | Cartão privado para o dono digitar uma senha ou chave; ninguém vê o valor. Sempre no lugar de pedir segredo no chat. |
| `t3_attachment_prepare_upload` | Prepara o envio de um arquivo e devolve `relativeUrl`. Depois, mande os bytes exatos do arquivo (POST) para esse endereço no servidor do T3 e só então use `t3_thread_send_attachments` com o `attachmentId`. O esquema limita o tamanho: 10 MB ou 50 MB, sem dizer qual vale para cada tipo (não confirmado). |
| `t3_attachment_discard` | 🔒 Só a pedido do dono. Descarta um envio preparado e ainda não enviado. |
