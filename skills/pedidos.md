# Pedidos: o registro do dono

Use sempre que o dono pedir algo. O pedido é a unidade de acompanhamento; o chat
intérprete é só quem executa. Só o maestro escreve neste registro.

## Onde fica

- `local/pautas/<projeto>.md`: a pauta de cada projeto, com os pedidos abertos e
  as decisões. Tarefas da máquina e do próprio maestro vão na pauta `casa`.
- `local/diario/<aaaa-mm-dd>.md`: só acréscimo, uma linha por mudança, na ordem em
  que acontece: hora, ID e o que mudou.
- `local/arquivo/<aaaa-mm>.md`: pedidos fechados há mais de 7 dias, uma linha cada.

## Idioma

Tudo o que vai para o dono sai no idioma de `local/config.md`: "Anotei", "já
estava anotado", o rodapé, o bloco "Desde a última vez", os nomes dos estados e
as marcas de verificação. As frases deste arquivo são exemplos em português; diga
o equivalente. Em inglês, por exemplo: "Noted: LJ-13, LJ-14." e "Open: 6 (2
waiting on you)." Os IDs não mudam.

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

| ID | Pedido | Desde | Estado | Onde | Prova | Publicado | Mudou em |
|---|---|---|---|---|---|---|---|
| LJ-12 | Resposta aparece abaixo da pergunta | 13/11 14:50 | conferido | Fila A | commit 28dd0eb, print lido | não | 13/11 16:10 |
| LJ-13 | Visão geral da fila | 13/11 15:02 | fazendo | Fila B | | | 13/11 17:40 |
| LJ-14 | Dica de como convidar pessoas (ver LJ-13) | 13/11 15:02 | anotado | | | | 13/11 15:02 |

## Decisões e autorizações

| Quando | O quê | Alvo | Situação |
|---|---|---|---|
| 13/11 15:30 | aprovou o merge | PR #12, commit 1b5160f | usada às 15:42 |
| 13/11 18:00 | desligou a demo | demo da Loja | vale até ele pedir de novo |
```

## Anotar

1. Quebre a mensagem do dono em entregas. Uma entrega é um pedido. Uma pergunta
   e uma mudança na mesma frase viram dois pedidos ligados ("ver LJ-13").
2. Antes de criar um ID, procure na pauta um pedido aberto com o mesmo sentido. Se
   houver, use o dele e diga "já estava anotado como LJ-9".
3. Anote antes de despachar. Comece a resposta com "Anotei: LJ-13, LJ-14.", no
   idioma do dono. Se nada novo foi anotado, não escreva essa linha.
4. A coluna "Pedido" resume a fala do dono sem mudar o sentido. Se ele mudar o
   pedido, reescreva a célula e anote a versão anterior no diário. Nunca apague
   um pedido: descarte com motivo.
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
que acontece se ele não responder. Depois disso ela só aparece em "Depende de
você", no `ketchup`, no `painel` e no resumo; não repita "ainda em aberto" em
outras respostas. Siga com o que não depende dela.

Toda aprovação vai para "Decisões e autorizações", com o alvo exato. Ordem de
parar ou desligar vale até o próprio dono revogar.

## Desde a última vez

`local/estado.md` guarda `Visto até:`, a hora do último resumo entregue ao dono.
O bloco mostra só as linhas do diário depois dessa hora, agrupadas por projeto, e
o cursor só avança depois que a resposta foi enviada. Na dúvida se o dono viu,
repita com os IDs: é melhor repetir que perder um pedido.

```
Desde 16:10
Loja: 4 conferidos (LJ-9 a LJ-12) · 1 esperando você (LJ-16) · 2 fazendo
Site: 1 conferido (ST-3)
Parado há mais de 2 h: LJ-15
```

## Rodapé

Se houver pedidos abertos, toda resposta ao dono termina com uma linha curta, no
idioma dele: "Abertos: 6 (2 esperando você)." Não vale para rotina sem novidade.
O dono desliga em `local/config.md` ("Rodapé de pedidos: não").

## Parados e órfãos

A rotina procura:

- **Parados:** `anotado` há mais de 2 horas sem chat; `fazendo` há mais de 45
  minutos sem atividade no chat.
- **Órfãos:** o intérprete disse que terminou e o pedido segue aberto; ou o pedido está
  `fazendo` e o chat está parado sem aviso.

Antes de dizer que algo travou, confira dois sinais: o registro e a atividade real
do chat.

## O índice: `local/estado.md`

Reescrito inteiro a cada mudança, nunca acrescentado. Teto: 120 linhas, 16 KB e
200 caracteres por célula. Modelo fictício:

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

## Chats vivos
| Título | Chat | threadId | Projeto | Executor | Estado | Pedidos | PR | Lido até | Último aviso |
|---|---|---|---|---|---|---|---|---|---|
| Fila B | <link> | <id> | Loja | Codex | rodando | LJ-13, LJ-14 | | 212 | 17:40 começou os testes |

## Vaga pesada
- Fila B: servidor de desenvolvimento desde 17:20, esperando o dono validar
- Na fila: Site A (instalação)

## Demo
- Loja: commit a1b2c3d, porta 4100, ligada; saúde conferida 17:55

## Rotinas
- T3 Monitor (<id>): ligada · T3 Resumo (<id>): 18:00 nos dias úteis
- T3 Atualização (<id>): 08:00 todo dia
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
- cursores (`Visto até`, `Lido até` de cada chat) e rotinas ligadas.

Reescreva em momento calmo e antes de tarefa longa. Depois que a conversa for
resumida, releia o `AGENTS.md` inteiro, o `VERSION`, `local/config.md`,
`local/estado.md` e `local/retomada.md` antes de agir, e reescreva a linha
`Regras carregadas:`.

## Ler os intérpretes

- `t3_thread_read` com `afterPosition` igual ao `Lido até`, `limit` de até 10 e
  `maxCharsPerItem` de até 4000. Guarde o `nextPosition` como novo `Lido até`.
- Texto cortado: continue com `itemId` e `textOffset` só se precisar dele.
- O resultado inteiro só é lido para repassar ao dono ou conferir a prova.
