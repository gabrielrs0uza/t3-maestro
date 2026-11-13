# Passar da v1 para a v2

Para quem já usa a versão antiga do maestro (a v1, sem número, com
`config.local.md` e `estado.md` soltos na pasta) e vai passar para a v2, que está
na `main` com a tag `v2.0.0`. O "maestro" é o chat com quem você fala; os
"intérpretes" são os chats que ele abre para executar.

## Versão curta

Para mandar numa mensagem:

```
Passar o maestro da v1 para a v2:
1. Na pasta do maestro: git status   (precisa estar limpo)
2. git switch main
3. git pull --ff-only
4. Diga ao maestro: "Releia o AGENTS.md inteiro e siga 'Ao começar'."
   (ou peça a ele que rode os passos 1 a 3 e pare se o git status não estiver limpo)
Ele faz backup, move config.local.md para local/config.md sem mudar seus valores
e guarda o estado.md antigo em local/arquivo/.
Voltar: bash scripts/maestro.sh voltar local/backups/<pasta que termina em -1.x-para-2.0.0>
        git switch -c v1 f947c1e   e diga ao maestro "Releia o AGENTS.md inteiro."
Achou algo? "sugira ao maestro: ..." ou mande ao mantenedor o que houve e a linha "RESULTADO:".
```

A versão completa vem a seguir.

## 1. Passar para a v2

Escolha um momento calmo. Intérpretes que estiverem trabalhando seguem com o
pedido que receberam; nada se perde, mas é mais fácil acompanhar a troca sem
nada pela metade.

Na pasta do maestro:

```
git status
git switch main
git pull --ff-only
```

- `git status` precisa dizer que não há nada a salvar. Se aparecer algum arquivo,
  pare e mostre ao mantenedor: não apague nem descarte nada para seguir.
  `config.local.md` e `estado.md` não aparecem, porque ficam fora do git.
- `git switch main` garante que você está na `main`.
- `git pull --ff-only` traz a v2 e só avança: se a sua `main` tiver commits
  próprios, ele para sem mexer em nada. Nesse caso, mostre ao mantenedor.

Depois, diga ao maestro, no mesmo chat de sempre:

> Releia o AGENTS.md inteiro e siga 'Ao começar'.

Se preferir, peça ao próprio maestro que rode os três comandos antes: "Rode na
pasta do maestro `git status`, `git switch main` e `git pull --ff-only`; se o
`git status` não estiver limpo ou o pull parar, pare e me mostre."

Dali em diante, a rotina diária confere as versões novas sozinha.

## 2. O que acontece na primeira vez

Ao seguir "Ao começar", o maestro confere os provedores disponíveis e roda
`scripts/maestro.sh atualizar --auto`. O script:

1. Faz backup do que é seu em `local/backups/<data>-1.x-para-2.0.0/`.
2. Move `config.local.md` para `local/config.md`. Nenhum valor seu muda; só
   entram os campos novos, com o valor padrão (tabela abaixo).
3. Guarda o `estado.md` antigo, igual, em `local/arquivo/estado-v1.md`, e cria um
   índice novo em `local/estado.md` com a linha "Migração da versão 1: pendente".
4. Pede ao maestro quatro tarefas: `MONTAR_PAUTAS`, `AVISAR_ATUALIZACAO`,
   `PERGUNTAR_PARALELO` e `CRIAR_ROTINA_ATUALIZACAO`.
5. Termina com `RESULTADO: atualizado 1.x -> 2.0.0; migrado 0 -> 2`.

Então o maestro:

- Registra este chat como o titular, na linha `Titular:` do topo de
  `local/estado.md`. Só o titular escreve em `local/`, abre intérpretes e cuida
  das rotinas. Se um dia você escrever em outro chat, ele pergunta se aquele deve
  assumir ou só responder uma dúvida.
- Diz "Regras em vigor: v2.0.0" e resume o que mudou.
- Monta as pautas e o índice a partir do estado antigo, aos poucos, sem apagar o
  arquivo antigo, e tira a linha "Migração da versão 1: pendente" ao terminar.
- Conta, em uma linha, que agora confere e prepara as versões novas sozinho, uma
  vez por dia; que aplica sozinho só documentação; que para qualquer outra
  mudança pede a sua confirmação, com o resumo e a lista de arquivos; e que basta
  dizer "não atualize sozinho" para desligar.
- Pergunta uma vez se pode abrir chats sozinho para pedidos novos e
  independentes, e grava a resposta em "Abrir chats sem perguntar". Até você
  responder, vale `perguntar`.
- Cria a rotina diária `T3 Atualização`, às 08:00, presa a este chat, sem
  duplicar se já existir.
- Se o seu revisor for `mesmo executor` e houver outro provedor disponível, ele
  oferece uma vez trocar o revisor, recomendando a troca. Só troca com o seu ok.

Campos novos do `local/config.md`, com o valor que entra. Mude o que quiser
pedindo ao maestro:

| Campo | Valor que entra |
|---|---|
| Abrir chats sem perguntar | `perguntar` (o maestro pergunta uma vez) |
| Chats rodando ao mesmo tempo | 4 |
| Vagas pesadas | 1 |
| Rodadas de revisão por PR | 3 |
| Rodapé de pedidos | sim |
| Pasta de provas | `local/provas` |
| Demo | nenhuma |
| Faxina | não quero |
| Faxina automática | não |
| Atualização automática | sim |
| Canal | estável |
| Origem das atualizações | `origin` |
| Exigir tag assinada | não |

## 3. O que muda no dia a dia

- **Pedidos com ID.** Cada pedido seu é anotado antes de qualquer coisa, e a
  resposta começa com "Anotei: LJ-13, LJ-14." Uma mensagem com duas entregas vira
  dois pedidos.
- **Rodapé.** Com pedidos abertos, a resposta termina com uma linha como
  "Abertos: 6 (2 esperando você).". Desliga com "Rodapé de pedidos: não".
- **Marcas de verificação.** Cada afirmação sobre o estado de algo vem com
  "conferi agora" (e como), "o intérprete disse, não conferi" ou "não sei".
- **Frentes em paralelo, com limite.** Pedidos independentes vão para chats
  diferentes ao mesmo tempo: até 4 rodando e 1 tarefa pesada por vez na sua
  máquina (servidor, build, instalação, navegador de teste).
- **Demo intocável.** A demo é uma versão aprovada, parada num commit, em que
  nenhum intérprete mexe. Só troca de versão quando você pedir, e o que você
  desligar só volta quando você pedir.
- **Revisão com limite.** Toda mudança de código passa por um revisor em outro
  chat, salvo se você escolheu não revisar, com até 3 rodadas por PR. Passou
  disso, a decisão é sua.
- **CI primeiro, se o repositório tiver CI.** O intérprete abre cedo um PR em
  rascunho, e a bateria pesada de testes roda no CI, não na sua máquina. Na
  máquina, só o teste rápido do que mudou e o localhost para você ver a tela.
  Rascunho não é publicação.
- **Faxina só relata.** Apagar caches sozinho, só se você ligar.
- **Estados novos.** "Pronto para revisar" saiu: agora é "em revisão", "PR
  aberto" ou "esperando você".

Merge, deploy, mudança em dados de produção e exclusões continuam pedindo a sua
aprovação, como antes.

## 4. O que fica preservado

- **`config.local.md`:** vira `local/config.md` com os mesmos valores, só com
  campos a mais. A cópia original fica em
  `local/backups/<data>-1.x-para-2.0.0/raiz/config.local.md`.
- **`estado.md`:** fica igual, byte a byte, em `local/arquivo/estado-v1.md`, e
  outra cópia em `local/backups/<data>-1.x-para-2.0.0/raiz/estado.md`.
- **Tudo em `local/`:** fica fora do git. Atualização nenhuma sobrescreve ou
  apaga o que está lá; o que muda de lugar vai antes para o backup.
- **Os intérpretes que já existem** continuam no T3, onde estão. O maestro os
  traz para as pautas ao montá-las.

## 5. Como voltar se der problema

Na pasta do maestro:

```
bash scripts/maestro.sh voltar local/backups/<pasta que termina em -1.x-para-2.0.0>
git switch -c v1 f947c1e
```

Depois diga ao maestro: "Releia o AGENTS.md inteiro." E peça a ele que pause a
rotina `T3 Atualização`: a v1 não tem a seção que ela manda seguir.

- O `voltar` devolve `config.local.md` e `estado.md` à pasta do maestro, iguais
  aos de antes, e guarda tudo o que a v2 tinha em `local/` (pautas, índice,
  config novo) em outro backup, `local/backups/<data>-antes-de-voltar/`.
- O `git switch -c v1 f947c1e` cria um branch seu, `v1`, com as regras da v1,
  o último commit dela. Por isso o script diz `RESULTADO: voltou 2.0.0 -> 2.0.0`:
  quem troca as regras é o `git switch`, não ele.
- Na v1, a pasta `local/` aparece como não rastreada no `git status`. Pode ficar
  lá: tem os backups.
- Se o `voltar` terminar com outra coisa que não `RESULTADO: voltou ...`, pare e
  mande a saída ao mantenedor.

## 6. Como contar o que achou

- **Pelo maestro:** diga "sugira ao maestro: ..." e o que aconteceu. Ele redige
  em `local/sugestoes/`, com um exemplo fictício, sem nomes, projetos ou caminhos
  seus, passa a conferência de privacidade, mostra o texto inteiro e só envia com
  o seu ok.
- **Direto ao mantenedor:** conte o que aconteceu e o que esperava, e copie a
  última linha `RESULTADO:` que o script mostrou. Não mande o seu config, o seu
  estado nem as pautas.

## Ensaio

O passo a passo foi ensaiado em 13/11/2026, no macOS, numa cópia da v1 com
config e estado fictícios: uma origem com a `main` na v1 que depois recebe a v2
num commit de merge com a tag `v2.0.0`, como no GitHub; o pull, a primeira
execução e a volta. Saída real, resumida; a pasta do ensaio aparece como
`<ensaio>`.

Antes, na v1, com `git status` limpo:

```
$ git log --oneline -1
  f947c1e Adapta o maestro a cada pessoa e leva a interface para dentro do T3
$ git status --short
```

Passo 1, a passagem pela `main`:

```
$ git switch main
  Already on 'main'
  Your branch is up to date with 'origin/main'.
$ git pull --ff-only
  From <ensaio>/origem
     f947c1e..8f5699c  main       -> origin/main
   * [new tag]         v2.0.0     -> v2.0.0
  Updating f947c1e..8f5699c
  Fast-forward
  (a lista de arquivos)
   56 files changed, 6468 insertions(+), 251 deletions(-)
```

Passo 2, o que "Ao começar" roda:

```
$ bash scripts/maestro.sh atualizar --auto
  ORIGEM REGISTRADA: <ensaio>/origem.git
  BACKUP: local/backups/20261113T230959Z-1.x-para-2.0.0
  MIGRAÇÃO: 001-pasta-local.txt
  TAREFA: MONTAR_PAUTAS
  MIGRAÇÃO: 002-campos-v2.txt
  TAREFA: AVISAR_ATUALIZACAO
  TAREFA: PERGUNTAR_PARALELO
  TAREFA: CRIAR_ROTINA_ATUALIZACAO
  BASE: 1.x -> 2.0.0
  FORMATO LOCAL: 0 -> 2
  NOVIDADES (do CHANGELOG):
  (a entrada 2.0.0 do CHANGELOG.md)
  RESULTADO: atualizado 1.x -> 2.0.0; migrado 0 -> 2
```

O que ficou:

```
$ ls local
  arquivo  backups  config.md  diario  estado.md  pautas  versao.md
$ git status --short

config: valores antigos intactos?
  sim (só acréscimos)
estado antigo guardado igual?
  sim
$ ls local/backups/20261113T230959Z-1.x-para-2.0.0/raiz
  config.local.md
  estado.md
```

Passo 3, a volta:

```
$ bash scripts/maestro.sh voltar local/backups/20261113T230959Z-1.x-para-2.0.0
  GUARDADO: o estado de antes de voltar está em local/backups/20261113T231000Z-antes-de-voltar
  RESULTADO: voltou 2.0.0 -> 2.0.0
$ git switch -c v1 f947c1e
  Switched to a new branch 'v1'
$ git log --oneline -1
  f947c1e Adapta o maestro a cada pessoa e leva a interface para dentro do T3

config.local.md de volta e igual?
  sim
estado.md de volta e igual?
  sim
$ git status --short
  ?? local/
```

O ensaio não cobre o que o maestro faz depois do script (montar as pautas,
perguntar, criar a rotina).
