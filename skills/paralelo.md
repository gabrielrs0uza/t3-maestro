# Paralelo: várias frentes sem fila única

Use ao decidir se um pedido vai para um chat novo, para um chat que já existe ou
para um lote.

## Autorização

O T3 só abre chat novo quando o dono pede. O campo "Abrir chats sem perguntar" de
`local/config.md` é esse pedido, dado de uma vez:

- `sim`: abra sem perguntar o chat de cada frente nova.
- `não`: antes de cada lote de chats novos, pergunte uma vez, com botões: "Abro 3
  chats: A, B e C?".
- `perguntar`: como `não`, e na primeira vez pergunte também se ele quer deixar
  `sim` de vez. Grave a resposta no config.

O chat de revisão de "Caminho até o merge" não depende deste campo. Se o T3 recusar
a abertura, pare e mostre o erro exato ao dono; não contorne com outra ferramenta.

## Chat novo, chat existente ou lote

- A unidade é o que será revisado e integrado junto: um PR, ou uma entrega sem
  código. Pedidos de unidades diferentes, ou de projetos diferentes, vão para chats
  diferentes, ao mesmo tempo.
- Continuação do mesmo problema vai para o mesmo chat.
- Pedidos novos da mesma unidade e da mesma área vão para o chat dono dela, num
  lote numerado em uma mensagem só (modelo em `mensagem-filho.md`), e não uma
  mensagem por pedido.
- Intérprete ocupado: mande na hora só o que muda o trabalho em curso. O resto espera o
  fim da vez dele e vai no próximo lote; anote no índice "lote pendente" e mande
  assim que chegar o aviso dele ou na próxima rotina, o que vier primeiro.
- Tarefa simples em um arquivo é um chat só, sem dividir.

## Áreas e integração

Antes de dividir uma unidade, escreva: o que bloqueia o resto, o que corre em
paralelo, o que é compartilhado e a menor divisão segura. Arquivos compartilhados,
como lockfile, schema, configuração e componentes comuns, têm um dono só ou ficam
para uma etapa em sequência.

- Cada trabalhador tem a área dele declarada no pedido ("você só altera X") e uma
  worktree empilhada na branch do PR: `baseRef` na branch e `startFromOrigin: false`.
- Um integrador por frente: o chat dono da branch. Ele traz um trabalhador por vez
  para a branch, roda os testes, e os outros atualizam. Quem conflitar resolve e
  testa de novo. Integrar aqui é juntar commits na branch do trabalho; merge de PR,
  na `main` ou deploy continuam pedindo o dono.
- Dois chats nunca alteram os mesmos arquivos ao mesmo tempo. Sobreposição vira
  sequência.
- Comece com um trabalhador. Só abra mais de dois na mesma frente depois que o
  primeiro mostrar que o pedido funciona.

## Rodadas de revisão

Uma rodada é um parecer do revisor sobre um commit. O limite por PR, para o mesmo
escopo, é o número de "Rodadas de revisão por PR" do config (3, por padrão).

Ao passar do limite, não abra revisor nem correção. Leve ao dono uma decisão, com
os achados que sobraram: aceitar como limites conhecidos, redesenhar, cortar escopo
ou descartar. Se ele não responder, a frente fica parada. Escopo novo aprovado pelo
dono começa a contagem de novo.

## Orçamento por peso

O limite é o que a máquina aguenta, não o número de chats. Os padrões valem até o
dono mudar em `local/config.md`:

- **Leves:** até 4 intérpretes rodando ao mesmo tempo ("Chats rodando ao mesmo
  tempo").
- **Pesado:** 1 vaga na máquina inteira ("Vagas pesadas"). Pesado é servidor de
  desenvolvimento, build, instalação de dependências, navegador de teste e
  container. Conta tudo: intérpretes, subagentes deles e revisores. A demo tem lugar
  próprio e fica fora da conta.

Frente que não cabe no limite de chats fica `anotado`, na ordem em que chegou.
Despache a próxima quando um chat terminar, e diga ao dono quantas estão na fila.

Quem distribui a vaga é você:

1. No pedido, diga se o intérprete tem a vaga ("Você tem a vaga pesada; avise quando
   liberar") ou não ("Sem vaga pesada: se precisar, peça ao maestro e espere").
2. Pedido de vaga chega pelo aviso do intérprete. Antes de dar, olhe a memória livre
   (`memory_pressure` no macOS, `free -g` no Linux). Sob pressão, espere.
3. Registre no índice quem está com a vaga, para quê e desde quando, e a fila de
   espera. Ao liberar, passe ao próximo da fila, na ordem dos pedidos.
4. Servidor que espera o dono validar segura a vaga. Se a validação passar de 2
   horas, peça ao intérprete para desligar o servidor e subir de novo quando o dono for
   ver.

Se a máquina entrar em pressão de memória, peça ao intérprete que está com a vaga para
desligar o que subiu e avise o dono com o tamanho do processo. Você não mata
processos; quem desliga é o chat dono deles. A demo nunca entra nessa conta.

O revisor não sobe servidor de desenvolvimento por padrão: lê, roda testes e
reproduz com scripts. Se só der para reproduzir no app rodando, ele pede a vaga.

Antes de aumentar qualquer número, meça: anote na pauta `casa` o pico de memória
de cada tarefa pesada (`ps -o rss= -p <pid>`) por alguns dias e só aumente com
folga medida.

### Com CI

Se o repositório tem CI, o que o CI roda não roda na máquina do dono, nem para
intérpretes nem para revisores. Local, só o rápido dos arquivos tocados e o
localhost para o dono ver a tela. A bateria pesada roda no CI, pelo PR em
rascunho de "Caminho até o merge". Exceção: reproduzir uma falha que o CI apontou
e o log não explica; isso pede a vaga pesada. Se o CI não roda em rascunho, a
bateria espera o PR sair do rascunho; não rode na máquina para adiantar.

Ao abrir um chat de código, confira você mesmo, sem ir além disso: se há CI
(`.github/workflows/` ou equivalente), se ele roda em PR de rascunho e se pushes
seguidos cancelam a rodada anterior (`concurrency` com `cancel-in-progress`).
Escreva isso na linha "CI" do `message`. Se não achar CI, pergunte ao dono uma
vez se o repositório testa em outro lugar e anote a resposta nas decisões da
pauta do projeto.

Sem CI, vale o orçamento acima. Ao contar ao dono que abriu o chat, diga que os
testes vão rodar na máquina dele.

## Revisor do mesmo provedor

Vale para os casos (b) e (c) da "Primeira conversa" do `AGENTS.md`, outro modelo do mesmo
provedor ou o mesmo modelo, e para `mesmo executor`, de configs antigos, que é
(b) se houver outro modelo, senão (c). Um revisor da mesma origem tende a achar
certo o que quem construiu achou certo. Por isso:

- O chat é novo e não vê a conversa de quem construiu: o `message` não leva o
  `threadId` nem as explicações dele, só o pedido, os critérios de aceite, a
  branch e o commit.
- O roteiro de ataque é o mesmo, com duas exigências a mais, que vão no
  `message` como em `skills/mensagem-filho.md`, "Para o revisor": cada achado
  traz um reprodutor, um teste que falha ou um script, com o comando e a saída;
  e o revisor roda ele mesmo os testes naquele commit e copia a saída (com CI,
  só o rápido dos arquivos tocados, mais o resultado do CI daquele commit).
- Ao repassar os achados, diga com todas as letras que a revisão veio do mesmo
  provedor, ou do mesmo modelo, de quem construiu, e que por isso a prova é mais
  fraca que a de outro provedor.

Antes de abrir esse revisor, chame `orchestrator_capabilities`. Nessa hora, e
quando ela for chamada em "Ao começar", confira: se o revisor é do mesmo provedor
porque não havia outro (`mesmo executor`, de configs antigos, conta como esse
caso) e agora há, ofereça uma vez trocar o revisor para o outro provedor,
recomendando a troca. Ao oferecer, anote no próprio campo Revisor de
`local/config.md`: `troca oferecida em <data>`, e depois a resposta. Com essa
nota, não ofereça de novo. Até ele responder, a revisão segue com o revisor
atual; só troque com o ok dele.
