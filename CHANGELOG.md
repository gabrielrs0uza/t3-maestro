# Mudanças

Cada versão estável tem uma tag `vX.Y.Z`. A atualização automática lê este arquivo
para contar ao dono o que mudou, por isso cada versão começa com o que muda para
quem já usa. Formato inspirado em [Keep a Changelog](https://keepachangelog.com/),
com versões no [SemVer](https://semver.org/): MAJOR muda o formato de `local/` ou
remove algo, MINOR traz novidade, PATCH corrige.

## [2.0.0] - 2026-11-13

### O que muda para quem já usa

1. Uma vez só: peça ao maestro para rodar `git pull --ff-only` na pasta do maestro
   e reler o `AGENTS.md`. Dali em diante, ele confere e prepara as versões novas
   sozinho, uma vez por dia; aplica sozinho só documentação e pede uma confirmação
   sua para o resto.
2. Seus arquivos mudam de lugar, com backup: `config.local.md` vira
   `local/config.md`, e o `estado.md` antigo fica guardado em `local/arquivo/`.
3. O config ganha campos novos com valor padrão; os seus valores não mudam. O
   maestro pergunta uma vez se pode abrir chats sozinho.
4. Cada pedido seu ganha um ID ("Anotei: LJ-13") e as respostas terminam com os
   pedidos abertos.
5. O maestro diz o que conferiu, o que o intérprete disse e o que não sabe.
6. Pedidos independentes rodam em paralelo, com uma tarefa pesada por vez.
7. A demo fica intocável, e o que você desligar só volta quando você pedir.
8. A revisão tem um limite de rodadas por PR; passou dele, a decisão é sua.
9. A faxina semanal só relata; apagar caches sozinho, só se você ligar.
10. "Pronto para revisar" saiu: agora é "em revisão", "PR aberto" ou "esperando você".

### Adicionado

- Registro de pedidos por projeto em `local/pautas/`, com diário, estados curtos,
  prova para "conferido", marca de "publicado" e o bloco "Desde a última vez"
  (`skills/pedidos.md`).
- Prova mínima por tipo de afirmação e as três marcas: "conferi agora", "o intérprete
  disse, não conferi" e "não sei".
- Frentes em paralelo com a autorização do dono no config, lote numerado, área por
  trabalhador, integrador e limite de rodadas de revisão (`skills/paralelo.md`).
- Orçamento por peso: até 4 chats rodando e 1 vaga pesada na máquina.
- Demo como palco protegido, com a cláusula intocável em todo pedido a um intérprete
  (`skills/demo.md`).
- Recibo de recursos e os passos encerrar, liberar e arquivar
  (`skills/recursos.md`).
- Faxina em modo relatório, com faxina automática do regenerável desligada por
  padrão (`skills/faxina.md`).
- Versão e atualização: `VERSION`, este arquivo, `ORIGEM.md`, `scripts/maestro.sh`,
  migrações declarativas em `migracoes/` e as skills `atualizar`, `sugerir` e
  `primeira-conversa`.
- A atualização confere e prepara cada versão nova antes do merge, com o script
  já instalado. Só entra sozinha a versão que muda apenas documentação (`README*`,
  `CHANGELOG.md`, `docs/`, `LICENSE`, `ORIGEM.md`, `VERSION`); qualquer outra pede
  uma confirmação do dono, com o resumo, a lista de arquivos e o diff completo. As
  migrações são declarativas, com operações, campos e tarefas de listas fechadas,
  e não seguem links. Origem e tags aplicadas ficam registradas, tag e `VERSION`
  precisam bater, tag assinada pode ser exigida, nada local é sobrescrito e toda
  operação pode ser interrompida e repetida. Versão com caractere de controle,
  bidi ou linha enorme no texto, ou com `.gitattributes` ou `.lfsconfig`, é
  recusada mesmo com o ok do dono. A trava só é retomada quando o processo dono
  morreu, e o `fetch` tem limites de rede.
- Modelo da mensagem ao intérprete em `skills/mensagem-filho.md`.
- README de apresentação, com banner para os temas claro e escuro, e sugestões
  para a página do repositório em `docs/pagina-github.md`.
- Cenários de regressão em `docs/cenarios.md`, decisões em `docs/DECISOES.md` e o
  teste da atualização em `tests/atualizacao.sh`, que roda no CI.

### Mudou

- Tudo o que é da pessoa fica em `local/`, fora do git.
- `local/estado.md` é um índice curto e reescrito, com teto de tamanho; o histórico
  vai para pautas, diário e arquivo, e há `local/retomada.md` para depois de a
  conversa ser resumida.
- O maestro lê os intérpretes a partir do último ponto lido e deixa investigação longa
  para um intérprete.
- O bloco de regras fixas do `AGENTS.md` fica marcado.
- A checagem de privacidade guarda os termos proibidos como hashes, compara
  grafias equivalentes (acentos, maiúsculas, Unicode decomposto), procura o termo
  dentro de palavras, em nomes com hífen e em frases, e confere também um arquivo
  avulso antes de uma sugestão sair da máquina (`tests/privacidade.sh`).

### Corrigido

- As duas regras de exclusão que se contradiziam agora estão juntas no bloco fixo,
  com as duas únicas exceções e seus limites.
- O estado "pronto para revisar" servia a duas revisões diferentes.

### Para a próxima versão

Limites conhecidos desta versão, sem data; o detalhe está em `docs/seguranca.md`.

- O gancho de teste `MAESTRO_PARAR_EM` só é lido do ambiente do processo; uma versão
  nova não consegue defini-lo sem a confirmação do dono.
- O backup copia arquivos ignorados da raiz, como `.claude/`, e segue links
  simbólicos ao copiar; tudo fica em `local/backups/`, na própria máquina.

## [1.x] - 2026-11-09

Versão sem número, até o commit `f947c1e`: maestro, um chat por problema,
`config.local.md` e `estado.md` na raiz.
