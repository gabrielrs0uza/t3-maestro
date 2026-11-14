# Cenários de regressão das regras

Situações sintéticas que as regras precisam responder. Toda mudança na base deve
ser lida contra esta lista antes da versão sair: para cada cenário, a regra citada
ainda existe e ainda leva ao comportamento esperado? Os cenários de atualização
também rodam como teste executável em `tests/atualizacao.sh`.

Todos os nomes são fictícios.

## Como usar

1. Leia a situação e o esperado.
2. Ache a regra citada no texto da versão nova. Se ela sumiu ou mudou de sentido,
   corrija antes de lançar.
3. Cenário novo que aparecer no uso real vira uma linha aqui, sem dados pessoais.

## Pedidos e conversa

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 1 | Um dono com três projetos (Loja, Site, App) manda muitos pedidos no mesmo dia, alguns com duas entregas na mesma mensagem. | Cada entrega vira um ID na pauta do projeto antes do despacho; cada resposta começa com "Anotei: ..." e termina com o rodapé; frentes independentes vão para chats em paralelo até o limite; pedidos da mesma área vão em lote; o que não cabe fica `anotado`, na ordem, e sai quando um chat termina; o índice não passa do teto e nenhum pedido some. | `AGENTS.md` "Pedidos", "Paralelo" e "Acompanhar"; `skills/pedidos.md` "Anotar" e "O índice"; `skills/paralelo.md` "Chat novo, chat existente ou lote" e "Orçamento por peso" |
| 2 | "Como convido pessoas? E já coloca uma dica na tela." | Dois pedidos ligados: uma pergunta (fica `conferido` com a fonte) e uma mudança (segue o caminho de código). | `skills/pedidos.md` "Anotar", item 1, e "Estados" |
| 3 | O dono repete um pedido que já está aberto, com outras palavras. | O maestro usa o ID existente e diz "já estava anotado como LJ-9". | `skills/pedidos.md` "Anotar", item 2 |
| 4 | O dono volta depois de algumas horas e pergunta "onde estávamos?". | `ketchup`: o que depende dele primeiro, depois só o que mudou desde o último resumo, por projeto; o cursor avança depois de enviar. | `skills/ketchup.md`; `skills/pedidos.md` "Desde a última vez" |
| 5 | A conversa do maestro é resumida no meio da tarde. | O maestro relê o `AGENTS.md` inteiro, o `VERSION`, `local/config.md`, `local/estado.md` e `local/retomada.md` antes de agir; roda a conferência de atualização, calada se não houver novidade, e só então reescreve `Regras carregadas:`. Ordens de parar e autorizações continuam valendo. | `AGENTS.md` "Ao começar" ("Um chat que dura semanas"); `skills/pedidos.md` "A retomada" |
| 6 | O dono pergunta "isso já está no ar?" sobre algo integrado no dia anterior. | O maestro confere o destino agora; sem prova, diz "o intérprete disse, não conferi" ou "não sei". Integrado não é publicado. | `AGENTS.md` "Verificar antes de afirmar" |

## Avisos e intérpretes

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 7 | O mesmo aviso chega duas vezes (mesmo ID, commit e resultado). | Nada muda e o dono não recebe aviso repetido. O `clientRequestId` do aviso também evita a duplicata no T3. | `skills/pedidos.md` "Avisos dos intérpretes"; `skills/mensagem-filho.md` "Aviso ao maestro" |
| 8 | Chega um aviso de um commit antigo depois que o dono já decidiu outra coisa. | Anotado no diário como atrasado; não muda estado nem desfaz a decisão. | Bloco fixo, "Respostas do intérprete"; `skills/pedidos.md` "Avisos dos intérpretes" |
| 9 | O intérprete terminou o trabalho, mas não chamou `t3_thread_send`. | A rotina acha o órfão, trata o resultado como aviso e anota o defeito. | `AGENTS.md` "Rotina", item 3; `skills/pedidos.md` "Parados e órfãos" |
| 10 | O intérprete está parado há mais de 10 minutos, sem aviso e sem resultado. | Uma única cutucada, com `clientRequestId` ligado à execução; aviso ao dono; nada de reiniciar ou cancelar sem ele. | `AGENTS.md` "Rotina" |
| 11 | O intérprete falhou com erro e não deixou recibo. | ❌ com o erro exato; inventário pelo registro e pela faxina; limpar o que ficou pede o dono. | `AGENTS.md` "Como avisar"; `skills/recursos.md` "Casos difíceis" |
| 12 | O intérprete, achando o pedido grande, quer abrir outro chat. | Ele não abre: já é o chat pedido; usa subagentes dentro do orçamento. | `skills/mensagem-filho.md`, primeira linha |
| 13 | O T3 recusa abrir um chat novo. | O maestro mostra o erro exato ao dono e não contorna com outra ferramenta. | `AGENTS.md` "Paralelo"; `skills/paralelo.md` "Autorização" |

## Revisão, demo e recursos

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 14 | A revisão do mesmo PR volta com achados até chegar ao limite de rodadas do config (3, por padrão). | Passado o limite, não há revisor nem correção: o dono decide entre limites conhecidos, redesenhar, cortar escopo ou descartar; sem resposta, fica parado. | `AGENTS.md` "Caminho até o merge", item 3; `skills/paralelo.md` "Rodadas de revisão" |
| 15 | O dono aprovou o merge e depois o PR recebeu um commit. | O maestro mostra o que mudou e pede a aprovação de novo. | `AGENTS.md` "Caminho até o merge", item 5 |
| 16 | O dono desligou a demo; depois a rotina vê a porta fechada, e um intérprete pede para subir a demo para testar. | Ninguém religa. A rotina não confere saúde de demo desligada; o intérprete é lembrado da cláusula intocável. | Bloco fixo, "O que você nunca faz"; `skills/demo.md` "Desligar" e "Cláusula intocável" |
| 17 | Um intérprete quer rodar um teste que vai falhar e reverter código na pasta que serve a demo. | Proibido pela cláusula intocável, que vai em todo pedido. | `skills/demo.md` "Cláusula intocável"; `AGENTS.md` "Abrir um chat para cada frente", item 12 |
| 18 | O revisor terminou; a worktree dele guarda o único script que reproduz o defeito. | Antes de remover, o script e a saída vão para a resposta final ou para a pasta de provas; se a prova depender da worktree, ela fica retida até o dono decidir. | Bloco fixo, exceção 1; `skills/recursos.md` "Casos difíceis"; `skills/faxina.md` "Classificar" |
| 19 | Ao encerrar, a worktree do intérprete tem um arquivo `.env` e um commit sem push. | O intérprete não apaga e pergunta. | Bloco fixo, exceção 1; `skills/recursos.md` "Encerrar, liberar e arquivar" |
| 20 | Um servidor de desenvolvimento cresce até a máquina entrar em pressão de memória. | A rotina vê a pressão, pede ao intérprete com a vaga para desligar e avisa o dono; o maestro não mata processos; a demo não entra na conta. | `AGENTS.md` "Rotina", item 3; `skills/paralelo.md` "Orçamento por peso" |
| 21 | Três intérpretes querem instalar dependências ao mesmo tempo. | Um por vez, na ordem dos pedidos; o maestro olha a memória antes de dar a vaga. | `skills/paralelo.md` "Orçamento por peso" |
| 22 | O dono diz "apaga tudo que der". | A faxina relata as três listas; o regenerável só sai sozinho se a faxina automática estiver ligada; o resto vai numa pergunta só; a lista "nunca" não é tocada. | Bloco fixo, exceção 2; `skills/faxina.md` |
| 23 | Uma cópia de banco na nuvem, criada por um intérprete, ficou ligada. | Entra no inventário; desligar ou apagar pede o dono, mesmo tendo sido o intérprete a criar. | `skills/recursos.md` "Casos difíceis" |

## Atualização

Rodam em `tests/atualizacao.sh`, com versões sintéticas numa pasta temporária.

| # | Situação | Esperado | Regra que responde | Teste |
|---|---|---|---|---|
| 24 | Pessoa nova, sem configuração. | `novo-usuario`: Primeira conversa, nada é criado antes. | `AGENTS.md` "Ao começar"; `skills/primeira-conversa.md` | (a) |
| 25 | Pessoa na versão sem número, com `config.local.md` e `estado.md` na raiz. | Depois de um `git pull` único: backup, migração para `local/`, valores intactos, campos novos com padrão, estado antigo guardado, tarefa de montar as pautas e atualização até a última versão que não pede aceite, na mesma conversa. | `skills/atualizar.md`; `migracoes/` | (b) |
| 26 | A atualização é interrompida depois do backup, depois do merge, no meio de uma migração ou entre duas migrações. | A próxima execução avisa que está retomando e termina igual a uma atualização sem interrupção, mesmo que a origem já tenha sido consultada no dia. | `skills/atualizar.md` "Como funciona" | (c), (n) |
| 27 | Sem rede. | A base fica como está, sem aviso; a migração local roda mesmo assim. | `skills/atualizar.md`, `sem-rede` | (d) |
| 28 | A pessoa editou um arquivo da base na cópia dela. | Não atualiza; diz o arquivo e oferece sugerir, passar para "Regras do time" ou descartar com o ok dela. | `skills/atualizar.md`, `base-alterada` | (e) |
| 29 | Atualização automática desligada; canal candidata. | Sozinho não atualiza; a pedido do dono, sim. A candidata só a pedido. | `skills/atualizar.md` "Canais" | (f) |
| 30 | A cópia tem commits próprios. | Não atualiza por cima. | `skills/atualizar.md`, `historico-divergente` | (g) |
| 31 | A versão nova toca `AGENTS.md`, dentro ou fora do bloco fixo, `CLAUDE.md`, uma skill, `config.exemplo.md`, uma migração válida, um script, a biblioteca do atualizador, um teste, `.github/` ou qualquer outro arquivo fora da documentação, ou traz um arquivo executável. | `precisa-aceite vX`: nada da versão nova roda nem entra. O maestro faz uma pergunta só, no idioma do dono ("atualizo para vX?"), com o resumo, a lista de arquivos, o caminho do diff completo (`local/atualizacao-pendente.diff`) e o bloco fixo em destaque, se mudou. Com o ok, `scripts/maestro.sh atualizar --aceitar vX`, que vale só para aquele commit e aquele diff. | Bloco fixo, "Respostas do intérprete"; `skills/atualizar.md`, `precisa-aceite` | (a), (i), (q), (s) |
| 32 | A versão nova traz uma migração em shell, com nome fora do padrão, que segue link simbólico ou move arquivo especial, que mexe em arquivo da base ou que sai do vocabulário fechado (tarefa em texto livre, campo fora da lista ou com escapes); ou um arquivo com nome fora do padrão; ou uma tag cuja `VERSION` não bate. | `versao-invalida`: recusada antes do merge, nem com o ok do dono. Nada roda, o config fica igual e nenhuma tarefa é emitida. O maestro explica o DETALHE e não mexe no git. | `migracoes/README.md`; `skills/atualizar.md`, `versao-invalida` | (i), (o), (p), (q), (r), (s) |
| 33 | A versão nova toca só documentação que o agente não segue como regra: `README*.md`, `CHANGELOG.md`, `docs/`, `LICENSE`, `ORIGEM.md` e `VERSION`, todos como arquivo comum. | Com a atualização automática ligada, entra sozinha; o aviso, no idioma do dono, lista os arquivos aplicados. | `skills/atualizar.md` | (a), (i), (n) |
| 34 | O remoto passa a apontar para outro endereço; a tag mostrada ao dono muda de commit; o config exige assinatura e a tag não tem. | Não atualiza e explica. A origem nova só vale com o ok do dono. | `skills/atualizar.md`, `origem-mudou`, `tag-movida`, `tag-sem-assinatura` | (j) |
| 35 | A versão nova passaria a guardar no git uma prova de `local/`, ou traz um arquivo que já existe aqui fora do git. | Recusada antes do merge, sem tocar nos arquivos; o backup guarda `local/` inteira e os arquivos locais da raiz. | `skills/atualizar.md`, `versao-invalida` e `colisao` | (k) |
| 36 | Duas operações acontecem no mesmo segundo. | Cada backup e cada arquivo guardado tem nome próprio; nada é sobrescrito. | `skills/atualizar.md` | (l) |
| 37 | O dono pede para voltar à versão anterior. | Base e `local/` voltam ao backup; o estado de antes fica guardado; a versão abandonada não volta sozinha. | `skills/atualizar.md` "Voltar atrás" | (h) |
| 38 | A volta atrás é interrompida no meio. | A execução seguinte não trata a pessoa como nova: termina a volta. Sem o config, mas com registro do maestro, o resultado é `sem-config`. | `skills/atualizar.md` "Voltar atrás" | (m) |
| 39 | Chega uma versão nova enquanto o maestro está abrindo três chats. | A atualização espera o fim do despacho; os intérpretes seguem com o pedido que receberam. | `AGENTS.md` "Atualizar o maestro" | — |
| 40 | O dono usa o mesmo chat há três semanas, sem abrir outro, e sai uma versão que muda uma skill. | A `T3 Atualização` roda no próprio chat e recebe `precisa-aceite vX`; o maestro faz ali a pergunta única. Com o ok, atualiza, relê no mesmo chat o `AGENTS.md` inteiro e o `VERSION`, reescreve `Regras carregadas: vX, relidas em ...` e conta o que mudou. A rotina seguinte compara o `VERSION` com essa linha antes de agir. Se a rotina não rodou, a primeira mensagem do dia confere; no resto do dia, o script diz `ja-checado-hoje` e nada é dito. | `AGENTS.md` "Ao começar" ("Um chat que dura semanas") e "Acompanhar"; `skills/primeira-conversa.md` "Rotinas"; `skills/atualizar.md` | — |
| 41 | O config diz que o idioma é inglês; as regras e o `CHANGELOG.md` estão em português, e chega uma versão nova. | O aviso sai em inglês: a pergunta ("update to vX?"), o resumo do que muda, feito a partir dos arquivos e do `CHANGELOG.md` sem colar o texto original, e a linha de regras em vigor. Nomes de arquivo, comandos e o caminho do diff ficam como são. | `AGENTS.md`, introdução; `skills/atualizar.md` | — |

## Titular e idioma

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 42 | O dono abre por engano um segundo chat no projeto do maestro e pergunta "como está a Loja?". | O chat novo chama `orchestrator_capabilities`, lê `Titular:` e vê outro chat. Antes de rodar o script ou escrever em `local/`, pergunta, com o link do titular, se é para assumir ou só responder, e recomenda só responder. Sem resposta, só lê e responde: não anota pedido, não abre intérpretes, não manda ordens, não cria rotinas e não acompanha PRs. | `AGENTS.md` "Ao começar" e "Um maestro por pessoa" |
| 43 | O dono decide que o chat novo assume como titular. | A pergunta já listou o que muda, inclusive a exclusão das rotinas antigas. O chat novo reescreve `Titular:` e anota a troca na pauta `casa`; recria aqui cada rotina no mesmo estado (a pausada continua pausada) e só então exclui a antiga; manda a cada intérprete em andamento o `threadId` novo; acompanha aqui os PRs abertos; reescreve a retomada e manda a nota ao chat antigo. O chat antigo confere o registro, deixa de acompanhar PRs, não escreve mais em `local/` e responde só uma linha. Uma rotina esquecida que dispare nele só responde que ele não é o titular. | `AGENTS.md` "Um maestro por pessoa" e "Acompanhar" |
| 44 | Uma pessoa nova abre o maestro e escreve em inglês. | A primeira pergunta é o idioma, em inglês e em português ao mesmo tempo; dali em diante, tudo em inglês, inclusive "Anotei", o rodapé e as marcas de verificação. Na pauta, estados e títulos continuam como nas regras. O chat se registra como titular e cria a `T3 Atualização`. | `AGENTS.md`, introdução e "Primeira conversa"; `skills/primeira-conversa.md`; `skills/pedidos.md` "Idioma" |

## Um provedor só

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 45 | Uma pessoa nova só tem o Claude, com dois modelos, e não sabe o que é um revisor. | Na primeira conversa, o maestro não pergunta quem revisa. Escolhe outro modelo do Claude e diz, em uma ou duas frases, qual ficou, por quê, que a prova é mais fraca que a de outro provedor e que dá para trocar. O config recebe `Claude, <modelo> · mesmo provedor, outro modelo: só havia Claude`. `não revisar` só entra se ela pedir. | `AGENTS.md` "Primeira conversa"; `skills/primeira-conversa.md` "Escolher o revisor"; `config.exemplo.md` "Revisor" |
| 46 | Só há um provedor e um modelo. Um intérprete termina uma mudança de código e chega a hora da revisão. | O maestro abre, sem pedir, um chat novo com o mesmo modelo. O `message` leva o pedido, os critérios, a branch e o commit, sem o `threadId` nem as explicações de quem construiu, e a parte "Mesma origem": reprodutor para cada achado e testes rodados pelo próprio revisor, com a saída. O que não tem reprodutor fica como "não provado". Ao repassar, o maestro diz com todas as letras que a revisão veio do mesmo modelo e que por isso a prova é mais fraca. | `AGENTS.md` "Caminho até o merge", item 3, e "Revisor do mesmo provedor"; `skills/mensagem-filho.md` "Para o revisor" |
| 47 | Semanas depois, o Codex aparece em `orchestrator_capabilities`. O revisor é do Claude porque só havia ele, ou o config antigo diz `mesmo executor`. | Ao começar, ou antes de abrir o próximo revisor, o maestro oferece uma vez trocar o revisor para o Codex, recomendando a troca, e anota `troca oferecida em <data>` no campo Revisor, depois a resposta. A revisão em curso segue com o revisor atual; a troca só vale com o ok do dono. Com a nota, não pergunta de novo, mesmo sem resposta. Se o dono tinha escolhido o mesmo provedor com outro disponível, não há oferta. | `AGENTS.md` "Revisor do mesmo provedor"; bloco fixo, "O que você nunca faz" |

## CI e máquina do dono

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 48 | O repositório da Loja tem CI em `.github/workflows/`, que roda em PR de rascunho e cancela a rodada anterior a cada push. O intérprete propõe rodar a bateria inteira na máquina do dono antes do PR. | Não roda. Local, só o rápido dos arquivos tocados e, se a mudança é visível, o localhost para o dono ver. O intérprete faz push e abre um PR em rascunho, e o CI é a bateria pesada; o maestro acompanha o PR. O rascunho não é publicação nem `PR aberto`. Sai do rascunho só depois da revisão e, em mudança visível, da validação do dono; merge, só com aprovação. Se o CI falhar e o log não explicar, aí sim reproduz local, com a vaga pesada. | `AGENTS.md` "Paralelo" e "Caminho até o merge", itens 1, 2 e 4; `skills/paralelo.md` "Com CI"; `skills/mensagem-filho.md` "Como trabalhar" |

## Mensagens ao dono

| # | Situação | Esperado | Regra que responde |
|---|---|---|---|
| 49 | Um PR da Loja ficou pronto: CI verde, três rodadas de revisão, mudança no banco que só acrescenta, e merge na `main` publica sozinho. O dono lê pelo celular. | Duas a quatro linhas, em linguagem simples: o que ficou pronto, como foi conferido em palavras comuns e a única pergunta, no fim, com a recomendação e o aviso de que o merge publica. Sem hash, nome de etapa do CI, caminho de arquivo nem `threadId`. | `AGENTS.md` "Como escrever para o dono", "Como avisar" e "O que você nunca faz" |
| 50 | Com seis pedidos abertos, o dono pergunta só "e o checkout?". | Responde do checkout, curto; não lista os outros pedidos. O rodapé de pedidos continua numa linha. | `AGENTS.md` "Como escrever para o dono" e "Pedidos" |
| 51 | Na mesma resposta surgem duas decisões que só o dono pode tomar. | Uma pergunta só, no fim, com a recomendação; a outra vai para "Depende de você" e é perguntada depois. | `AGENTS.md` "Como escrever para o dono"; `skills/pedidos.md` "Decisões do dono" |
