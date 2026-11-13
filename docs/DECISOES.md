# Decisões de projeto

Por que a versão 2.0.0 é como é. As regras estão no `AGENTS.md` e nas skills; aqui
fica o motivo de cada escolha e o que foi descartado.

## Uma conversa, pedidos com número

- **Um maestro só, com uma pauta por projeto em arquivo.** Um coordenador por
  projeto poria mais um intermediário entre o dono e o trabalho.
- **O pedido é a unidade de acompanhamento, não o chat.** Uma mensagem pode ter
  várias entregas, e uma entrega pode passar por vários chats. Cada pedido tem um
  ID e é anotado antes de ser despachado.
- **Registro em Markdown, com o maestro como único escritor.** Sem banco nem script
  enquanto a regra em texto funcionar; um escritor só evita que avisos repetidos ou
  atrasados sobrescrevam uma decisão mais nova.
- **Sete estados de pedido e "publicado" como marca à parte.** Integrado não é
  publicado, e um pedido parado por dependência diz de quem depende no próprio
  estado. Mais estados virariam burocracia para pedido pequeno.
- **"Desde a última vez" por hora.** Com um escritor só, o diário fica em ordem, e a
  hora do último resumo serve de cursor. O cursor só avança depois que a resposta
  saiu.
- **Prova mínima por tipo de afirmação, e ela vale para um commit.** "O intérprete
  disse" não é "conferi agora"; commit novo pede prova nova.

## Contexto que não cresce

- **`local/estado.md` é um índice reescrito, com teto de 120 linhas e 16 KB.** O
  histórico vai para pautas, diário e arquivo. O teto move detalhe de lugar; nunca
  corta decisão, autorização ou pedido aberto.
- **Leitura dos intérpretes a partir do último ponto lido.** O resultado inteiro
  só é lido para repassar ou conferir.
- **O maestro não investiga.** O critério é o custo de contexto: fato curto é com
  ele, leitura longa vai para um intérprete. Contar chamadas de ferramenta foi
  descartado, porque uma chamada pode custar mais que quatro.
- **Retomada reescrita, não acumulada,** e relida depois que a conversa é resumida.

## Paralelo e orçamento

- **O dono autoriza de uma vez, no config, que o maestro abra chats.** O T3 só abre
  chat novo a pedido do usuário; o campo é esse pedido. A migração grava
  `perguntar` e manda perguntar uma vez, em vez de presumir a autorização.
- **Intérprete ocupado recebe só o que muda o trabalho atual.** O resto vira lote,
  enviado quando ele avisa ou na próxima rotina.
- **Limite de rodadas de revisão por PR, configurável, 3 por padrão.** Passou do
  limite, o dono decide: aceitar os limites conhecidos, redesenhar, cortar escopo
  ou descartar.
- **Orçamento por peso: até 4 chats leves e uma vaga pesada na máquina.** Pesado é
  servidor de desenvolvimento, build, instalação, navegador de teste e container,
  de qualquer chat, subagente ou revisor. O número só aumenta depois de medido.
- **O maestro distribui a vaga por mensagem.** Uma trava em arquivo exigiria que
  todo intérprete escrevesse fora da própria worktree, o que alguns executores com
  sandbox não podem.
- **Sob pressão de memória, quem desliga o processo é o chat dono dele.** O maestro
  nunca mata processo.

## Demo, recursos e exclusões

- **Demo copiada de um commit, sem `.git`, servida por um processo fora de
  qualquer chat.** `git worktree lock` impede remover a pasta, não editá-la. Trocar
  de versão passa por uma candidata em porta temporária.
- **Recibo de recursos com PID e hora de início.** O PID sozinho se repete.
- **Encerrar, liberar e arquivar são passos separados.** Arquivar um chat não
  libera disco.
- **Duas exceções de exclusão, ambas no bloco fixo.** O intérprete apaga, ao encerrar,
  o que ele mesmo criou na máquina; recurso remoto fica de fora. E a faxina
  automática apaga caches e dependências reinstaláveis, só se o dono ligar. Worktree
  nunca entra nessa lista, porque pode guardar prova.
- **A faxina começa só relatando.** O dono vê o que seria apagado antes de decidir
  ligar a parte automática.

## Base, local e atualização

- **Tudo o que é da pessoa fica em `local/`, fora do git.** Uma pasta só é uma
  linha no `.gitignore` e uma conferência no CI.
- **A cópia de cada pessoa é um clone do git e segue tags.** O canal estável é o
  único que se atualiza sozinho; candidatas (`-rc`) só a pedido; `main` fica com
  quem mantém.
- **A conferência da versão nova é feita pelo script já instalado, antes de
  qualquer merge e sem rodar nada que veio da origem.** É o script em que o dono já
  confia; o que acabou de chegar ainda não foi aceito.
- **"Atualização automática" quer dizer conferir e preparar sozinho, e aplicar
  sozinho só documentação.** Entram sem o dono só `README*`, `CHANGELOG.md`,
  `docs/`, `LICENSE`, `ORIGEM.md` e `VERSION`, em arquivo comum. Qualquer versão que
  toque `AGENTS.md`, dentro ou fora do bloco fixo, `CLAUDE.md`, skills, config de
  exemplo, migrações, scripts, testes, CI ou outro arquivo pede uma confirmação do
  dono, no mesmo chat, com o resumo, a lista de arquivos e o diff completo; o bloco
  fixo tem destaque. Texto de regra é instrução para um agente com acesso total, e
  a precedência do bloco fixo não basta como barreira: ele nunca entra sem o dono
  ver. Foi descartado deixar entrar sozinho texto de regra fora do bloco fixo.
- **O aceite vale para a versão, o commit e o diff que o dono viu.** O diff inteiro
  fica em arquivo, sem cortes, e o aceite confere o hash dele. Se a tag ou o diff
  mudarem, o aceite não vale.
- **Uma versão incoerente é recusada, nem com aceite.** Tag cujo `VERSION` não bate,
  arquivo com nome fora de `[A-Za-z0-9._/-]`, migração fora de `NNN-nome.txt` ou do
  vocabulário, e versão que passaria a guardar `local/` no git.
- **Migrações declarativas, com vocabulário fechado.** O script instalado lê cada
  linha e só sabe criar pastas e mover arquivos comuns para `local/`, sem seguir
  links em nenhuma parte do caminho; acrescentar campos de uma lista fechada, com
  valores aceitos por campo e gravados sem interpretar escapes, nunca em "Regras do
  time"; e pedir tarefas por código fechado, cujo significado está na skill já
  instalada. Shell baixado nunca roda. Texto livre vindo de uma versão nunca vira
  ordem.
- **Origem fixada.** O endereço da origem e o commit de cada tag aplicada ficam em
  `local/versao.md`. Origem trocada, tag movida ou histórico que não descende da
  versão instalada não atualizam. Limites aceitos: a origem é confiada no primeiro
  uso, e tag assinada é opcional no config, porque exige chave configurada em cada
  máquina.
- **Nada local é sobrescrito.** Versão que passaria a guardar no git algo de
  `local/` é recusada, mesmo com aceite; versão que traz arquivos que já existem
  aqui fora do git não entra. O backup guarda `local/` inteira e os arquivos da
  raiz que o git não acompanha, e todo nome novo é exclusivo.
- **Toda operação pode ser interrompida e repetida.** A atualização tem trava e
  migrações gravadas uma a uma; a volta atrás anota suas fases; a checagem diária
  da origem nunca impede concluir uma atualização local que ficou pela metade.
- **Com a atualização automática desligada, as migrações locais rodam mesmo
  assim.** Sem elas, a base que já está no disco não funciona com o local antigo.
- **Atualização automática ligada por padrão.** A migração avisa o dono e diz como
  desligar.
- **O aviso ao dono diz o que mudou de fato:** a lista de arquivos aplicados, não
  só o changelog.
- **Lista de termos proibidos como hashes.** A checagem de privacidade precisa da
  lista, e uma lista em texto claro exporia justamente o que protege. Termo e texto
  passam pela mesma forma comparada (sem acentos, minúsculas, só letras e números),
  e a busca confere substrings de palavras e de nomes com hífen, e frases. A lista
  guarda também o tamanho de cada termo, para a busca por substring ser rápida;
  isso revela só quantas letras o termo tem.

- **A lista de documentação é rasa e fechada.** `README.md` e `README.<idioma>.md`
  na raiz, `CHANGELOG.md`, `LICENSE`, `ORIGEM.md`, `VERSION`, `docs/<nome>.md` sem
  subpastas e imagens em `docs/assets/`. Componente que começa com ponto e nome de
  arquivo de instrução de agente (`AGENTS*`, `CLAUDE*`, `GEMINI*`, `SKILL.md` e
  parecidos), sem diferenciar maiúsculas, sempre pedem confirmação: um agente pode
  carregá-los como regra a partir de subpastas.
- **O que é da pessoa é conferido sem diferenciar maiúsculas.** Num disco do macOS,
  `Local/x` grava em `local/x`.
- **Texto com byte NUL é recusado, e todo diff é mostrado como texto.** Senão o
  dono veria "Binary files differ" no lugar da regra.
- **Recusar é mais simples que escapar.** Caractere de controle (CR solto, ESC,
  C1), bidi, largura zero, BOM e linha com mais de 2000 bytes fazem a versão ser
  recusada, em vez de aparecerem escapados no diff: assim o diff que o dono lê é o
  texto que vai para o disco.
- **`.gitattributes` e `.lfsconfig` são recusados, e os atributos de fora são
  neutralizados.** Filtros, `diff=`, `-diff` e LFS fariam o diff mostrar uma coisa
  e o disco guardar outra.
- **A trava não vence por idade.** Uma atualização longa não perde a trava;
  ela só é retomada quando o processo dono morreu.
- **O que ficou para a 2.1** está em `CHANGELOG.md` e em `docs/seguranca.md`.

## Uma conversa que dura semanas

- **A conferência de atualização não depende de abrir chat novo.** Ela roda numa
  rotina diária presa ao chat do dono, na primeira mensagem do dia e depois de a
  conversa ser resumida; no máximo uma vez por dia.
- **Um maestro por pessoa.** O chat titular fica registrado em `local/estado.md`;
  um segundo chat pergunta se assume ou só responde, em vez de escrever o mesmo
  estado.
- **Tudo o que o maestro diz ao dono sai no idioma do config.** O idioma em que as
  regras ficam escritas é outra decisão, em `docs/idiomas.md`.

## Revisão e máquina do dono

- **Revisor escolhido por ordem, sem perguntar como configurar:** outro provedor;
  senão outro modelo; senão o mesmo modelo em chat novo. "Não revisar" só por
  escolha do dono. Com revisor do mesmo provedor, a prova é mais fraca e o aviso
  diz isso; o revisor traz reprodutor e roda os testes.
- **O que o CI roda não roda na máquina do dono.** Com CI, o intérprete abre cedo
  um PR em rascunho e o CI vira a bateria pesada; rascunho não é publicação, e
  sair dele continua exigindo revisão e, em mudança visível, a validação do dono.

## Estados de chat

- **"Pronto para revisar" saiu.** Servia à revisão independente, antes do PR, e à
  decisão de merge, depois. Ficaram `em revisão`, `PR aberto` e `esperando você`.
- **Aprovação de merge vale para o PR como estava.** Commit novo depois da
  aprovação: mostrar o que mudou e pedir de novo.

## Fora desta versão

- Skills no formato `SKILL.md` e distribuição como plugin: só quando houver
  necessidade concreta; o clone com tags já resolve versão e atualização.
- Trocar o maestro por um novo quando a conversa fica grande: a retomada e a
  leitura incremental resolvem o mesmo problema sem quebrar a conversa única.
- Supervisor de memória que mata processos: só observação e pedido ao chat dono.
