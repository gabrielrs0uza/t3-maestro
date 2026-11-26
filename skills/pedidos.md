# Pedidos: o registro do dono

Use quando o dono pedir algo que precisa de acompanhamento. O pedido é a unidade
de acompanhamento; o chat intérprete é só quem executa. Só o maestro escreve neste
registro. O registro é memória interna: serve para retomar o trabalho entre
conversas, não para aparecer nas respostas.

## Onde fica

- `local/pautas/<projeto>.md`: a pauta de cada projeto, com os pedidos abertos e
  as decisões. Tarefas da máquina e do próprio maestro vão na pauta `casa`.
- `local/diario/<aaaa-mm-dd>.md`: só acréscimo, uma linha por mudança, na ordem em
  que acontece: hora, ID e o que mudou.
- `local/arquivo/<aaaa-mm>.md`: pedidos fechados há mais de 7 dias, uma linha cada.

## Idioma

Tudo o que vai para o dono sai no idioma de `local/config.md`, inclusive o bloco
"Desde a última vez" e, quando aparecem, os estados e as marcas de verificação.
As frases deste arquivo são exemplos em português; diga o equivalente. Os IDs não
mudam.

Nos arquivos de `local/`, os estados, os títulos, os nomes de coluna e as linhas
`Titular:`, `Regras carregadas:` e `Visto até:` ficam escritos como aqui, porque as
rotinas os procuram. O texto livre, como o resumo de cada pedido, pode estar no
idioma do dono.

## A pauta

Exemplo fictício:

```
# Pauta: Loja

Prefixo: LJ · Próximo ID: LJ-15
Agora: checkout novo em revisão; o dono quer o PR antes de sexta.

## Pedidos

| ID | Pedido | Estado | Chat | Prova | Mudou em |
|---|---|---|---|---|---|
| LJ-12 | Resposta aparece abaixo da pergunta | conferido, publicado | Fila A · <link> · <threadId> | commit 28dd0eb, print lido | 13/11 16:10 |
| LJ-13 | Visão geral da fila | fazendo | Fila B · <link> · <threadId> | | 13/11 17:40 |
| LJ-14 | Dica de como convidar pessoas (ver LJ-13) | anotado | | | 13/11 15:02 |

A coluna "Chat" guarda o link e o `threadId` de quem executa: é assim que você
manda ordens e lê o chat, sem uma tabela de chats à parte.

## Áreas em uso

| Chat | Só altera |
|---|---|
| Fila B | `src/fila/`, `tests/fila/` |

## Decisões e autorizações

| Quando | Palavras do dono | O quê | Alvo | Situação |
|---|---|---|---|---|
| 13/11 15:30 | "pode juntar o 12" | aprovou o merge | PR #12, commit 1b5160f | usada às 15:42 |
| 13/11 18:00 | "desliga a demo" | desligou a demo | demo da Loja | vale até ele pedir de novo |

## Segurado

| O quê | Por quê | Solta quando |
|---|---|---|
| PR #14 (carrega o #13) | o #13 espera o dono | o dono aprovar o #13 |
```

Pautas antigas, sem "Áreas em uso" e "Segurado", com as colunas "Desde", "Onde"
e "Publicado" ou sem "Palavras do dono", continuam valendo; ao reescrever, use
este modelo.

## Anotar

1. Anote só o que precisa de acompanhamento: entregas, decisões, aprovações e
   restrições, e ordens de pausar ou parar. Pergunta pontual, comentário,
   confirmação ou explicação que você responde na hora não vira pedido. Quebre
   em entregas o que sobrar: uma entrega é um pedido.
2. Antes de criar um ID, procure na pauta um pedido aberto com o mesmo sentido. Se
   houver, use o dele. Ajuste, correção ou nova etapa da mesma entrega atualiza o
   mesmo pedido, sem ID novo.
3. Anote antes de despachar, sem anunciar: ao dono, diga em palavras simples o
   que vai acontecer. IDs e estados só se ele pedir acompanhamento detalhado ou se
   o ID for indispensável para separar duas coisas numa decisão.
4. A coluna "Pedido" resume a fala do dono sem mudar o sentido. Se ele mudar o
   pedido, reescreva a célula e anote a versão anterior no diário. Nunca apague
   um pedido: descarte com motivo. Feedback de tela, print ou referência que ele
   deu vai ao intérprete como veio: as palavras dele entre aspas e a imagem.
5. Toda ordem a um intérprete cita os IDs, e o intérprete responde por ID.

## Estados

`anotado` → `fazendo` → `feito, não conferido` → `conferido`.

- `esperando você`: decisão ou validação que só o dono pode dar.
- `pausado`: o dono pediu para deixar para depois.
- `descartado`: o dono desistiu, ou o pedido entrou em outro; diga qual.
- Dependência vai junto do estado: "fazendo (depois de LJ-3)".
- `conferido` exige a prova mínima do `AGENTS.md`, lida pelo maestro. Sem ela, o
  máximo é `feito, não conferido`. Pergunta respondida fica `conferido`, com a
  fonte na coluna "Prova".
- Commit novo depois da prova devolve o pedido para `feito, não conferido`.
- "Publicado" é uma marca à parte: `sim` só com a prova de que o destino mostra
  aquela versão. Integrado não é publicado.

## Avisos dos intérpretes

- Repetido (mesmo ID, mesmo commit, mesmo resultado): não muda nada e não vira
  aviso ao dono.
- Atrasado (commit mais velho que o já registrado, ou anterior a uma decisão
  nova do dono): anote no diário como atrasado. Não muda estado nem desfaz decisão.
- Resultado pronto sem aviso (o intérprete terminou e não chamou `t3_thread_send`): é
  defeito. Trate o resultado como aviso e anote o defeito no diário.

## Decisões do dono

Pergunte uma vez, na resposta em que a decisão surgiu, com sua recomendação e o
que acontece se ele não responder. Uma pergunta por mensagem, no fim, como em
"Como escrever para o dono" do `AGENTS.md`; se surgirem duas, a outra entra em
"Depende de você" e é perguntada depois. A única exceção é o pacote de decisões,
abaixo, e só nos gatilhos dele. Depois disso ela só aparece em "Depende de
você", no `ketchup`, no `painel` e no resumo; não repita "ainda em aberto" em
outras respostas. Siga com o que não depende dela.

Toda aprovação vai para "Decisões e autorizações", com as palavras dele e o alvo
exato. Ordem de parar ou desligar vale até o próprio dono revogar.

## Pacote de decisões

A única exceção a "uma pergunta por mensagem": tudo o que espera o sim do dono,
numa lista numerada em que cada item tem a sua recomendação e o seu sim. Só
nestes gatilhos: no topo do resumo diário, se houver algo esperando; quando ele
pedir ("o que depende de mim?", "pendências"); quando juntarem 3 decisões ou mais,
uma vez, no lugar de perguntas soltas; e antes de pedir merge de risco (dinheiro,
dados, privacidade, migração, ou repositório em que merge publica), na versão
longa. Fora deles, vale a regra antiga: uma pergunta, no fim. O pacote não vai no
fim de toda mensagem.

Primeiro os sins que só ele dá; depois o que só ele sabe (o quê, onde achar, o que
mandar de volta; segredo só por `request_secret`); por último o que é só
confirmar. Cada item:

```
1. Juntar o PR do checkout novo? Merge aqui já publica.
   Recomendo: sim.
   Se sim: entra no ar em minutos. Se não responder: fica parado, nada publica.
   De onde vem: CI passou neste commit (conferi agora); revisão sem bloqueio.
   Dá para desfazer? Sim, desfazendo o merge.
```

A versão longa acrescenta o que não foi testado, até onde dá para voltar atrás e
o que fica para outro sim. Ele responde por número ("1 sim, 2 depois") ou por
botões (`AskUserQuestion`, até 4 itens por vez, só dentro do pacote). Mostrar o
pacote não é pedir de novo: item sem resposta continua esperando, e cada sim vale
só para o seu item.

## Desde a última vez

`local/estado.md` guarda `Visto até:`, a hora do último resumo entregue ao dono.
O bloco mostra só as linhas do diário depois dessa hora, agrupadas por projeto, e
o cursor só avança depois que a resposta foi enviada. Na dúvida se o dono viu,
repita: é melhor repetir que perder um pedido. O exemplo abaixo traz IDs e
contagens; ao dono, só se ele pediu acompanhamento detalhado. No resto, diga em
palavras simples.

```
Desde 16:10
Loja: 4 conferidos (LJ-9 a LJ-12) · 1 esperando você (LJ-16) · 2 fazendo
Site: 1 conferido (ST-3)
Parado há mais de 2 h: LJ-15
```

## Contagens

Contagem de pedidos abertos só aparece no resumo diário e no `painel`, nunca no
fim de cada resposta. O campo antigo "Rodapé de pedidos", do config, não tem mais
efeito.

## Parados e órfãos

O resumo diário procura, e a `T3 Monitor` também, se o dono a ligou:

- **Parados:** `anotado` há mais de 2 horas sem chat; `fazendo` há mais de 45
  minutos sem atividade no chat.
- **Órfãos:** o intérprete disse que terminou e o pedido segue aberto; ou o pedido está
  `fazendo` e o chat está parado sem aviso.

Antes de dizer que algo travou, confira dois sinais: o registro e a atividade real
do chat.

## O índice: `local/estado.md`

Reescrito inteiro a cada mudança, nunca acrescentado. Teto: 120 linhas, 16 KB e
200 caracteres por célula. Não há tabela de chats: o estado de cada chat está na
barra lateral do T3, e o link de cada um, na pauta. Um índice antigo com "Chats
vivos" perde essa seção na próxima reescrita, depois de passar para a pauta o
link e o `threadId` de cada pedido aberto. Modelo fictício:

```
# Estado

Titular: <threadId> · desde 02/11 09:00
Regras carregadas: v2.0.0, relidas em 13/11 08:02
Atualizado: 13/11 18:05 · Visto até: 13/11 16:10

## Depende de você
- LJ-16: entra neste PR ou no próximo? Recomendo o próximo; sem resposta, fica no próximo.

## Pautas
| Projeto | Arquivo | Abertos | Esperando você |
|---|---|---|---|
| Loja | local/pautas/loja.md | 6 | 1 |
| casa | local/pautas/casa.md | 1 | 0 |

## Vaga pesada
- Fila B: servidor de desenvolvimento desde 17:20, esperando o dono validar
- Na fila: Site A (instalação)

## Demo
- Loja: commit a1b2c3d, porta 4100, ligada; saúde conferida 17:55

## Rotinas
- T3 Atualização (<id>): 08:00 todo dia · T3 Resumo (<id>): 18:00 nos dias úteis
```

As duas primeiras linhas nunca saem. `Titular:` diz qual chat é o maestro, como em
"Um maestro por pessoa" do `AGENTS.md`; sem ela, o chat atual se registra.
`Regras carregadas:` diz a versão das regras que este chat leu por último, e só é
reescrita depois de ler, na mesma vez, o `AGENTS.md` inteiro e o `VERSION`, como em
"Ao começar" do `AGENTS.md`. Um índice antigo, ou o vazio que o script cria, pode
não ter essas linhas, ou trazer só `Regras: vX`: ao reescrever, use este modelo.

O que não cabe vai para a pauta, para o diário ou para `local/arquivo/`. O índice
nunca perde uma decisão, uma autorização ou um pedido aberto.

## A retomada: `local/retomada.md`

Reescrita, nunca acumulada, com no máximo 60 linhas:

- o que está em curso e o próximo passo de cada frente;
- decisões e autorizações vigentes, inclusive ordens de parar ou desligar;
- cursores (`Visto até` e até onde você leu cada chat) e rotinas ligadas.

Reescreva em momento calmo e antes de tarefa longa. Depois que a conversa for
resumida, releia o `AGENTS.md` inteiro, o `VERSION`, `local/config.md`,
`local/estado.md` e `local/retomada.md` antes de agir, e reescreva a linha
`Regras carregadas:`.

## Ler os intérpretes

- `t3_thread_read` com `afterPosition` igual ao ponto guardado na retomada,
  `limit` de até 10 e `maxCharsPerItem` de até 4000. Guarde o `nextPosition`.
- Texto cortado: continue com `itemId` e `textOffset` só se precisar dele.
- O resultado inteiro só é lido para repassar ao dono ou conferir a prova.
