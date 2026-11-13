# Faxina: medir, classificar e só então apagar

Use na rotina `T3 Faxina` ou quando o dono escrever "faxina". A faxina começa
sempre em modo relatório: lista o que apagaria e não apaga nada.

## Quem faz

Um intérprete chamado `Faxina`, com `scratch: true`, anotado como pedido da pauta
`casa`. Reaproveite o mesmo chat a cada vez; o `threadId` dele fica no índice. Ele
lê os inventários de `<pasta do maestro>/local/recursos.md` e `local/estado.md` e
não muda nada sem a ordem do maestro.

## Medir

- Disco livre (`df -h`) e pressão de memória (`memory_pressure` no macOS, `free -g`
  no Linux).
- Worktrees de cada projeto (`git worktree list --porcelain`): tamanho (`du -sh`),
  se estão limpas, commits sem push, branch já integrada, chat dono.
- Processos escutando portas (`lsof -iTCP -sTCP:LISTEN -P`), com PID, hora de
  início e comando.
- Containers, imagens e volumes (`docker ps -a`, `docker system df`), se houver
  Docker.
- `local/backups/` e a pasta de provas do maestro.
- A pasta de rascunhos do T3: só listar.

## Classificar

| Regenerável | Pede aprovação | Nunca |
|---|---|---|
| `.next`, `.turbo`, `dist` e `node_modules` dentro de worktree criada pelo maestro, sem processo rodando nela, fora da demo | toda worktree, mesmo limpa e integrada; branch; commit sem push; arquivo não rastreado | pasta, porta, processo, supervisor e banco da demo |
| | container, imagem e volume; processo de dono desconhecido | `git checkout`, `reset` ou `clean` na pasta da demo |
| | worktree de revisão, que pode guardar prova | `docker system prune --volumes` |
| | backups do maestro em `local/backups/` | pasta de dados de banco; checkout principal de cada projeto |
| | recurso remoto | qualquer comando com `--force` sem a aprovação daquele item |

Recurso que aparece em `local/recursos.md` como `em uso` ou `retido` não entra na
primeira coluna. Na dúvida, vai para a segunda.

## Relatar

Uma linha ao dono, e a lista se ele quiser ver:

"Faxina: apagaria 3,1 GB regeneráveis (faxina automática desligada); 4 itens
pedem sua decisão; nada da lista 'nunca' foi tocado."

Os itens que pedem aprovação vão numa pergunta só, com botões: aprovar a lista,
escolher item por item, ou nada. O intérprete só apaga o que foi aprovado, sem
`--force`, e manda o recibo com os GB liberados.

## Faxina automática

Desligada por padrão. Só o dono liga, pedindo nesta conversa; aí você grava
"Faxina automática: sim" em `local/config.md`. Ligada, o intérprete apaga sozinho só a
primeira coluna, depois de reconferir na hora que nada roda na worktree, que ela
não é da demo e que foi criada pelo maestro, e relata o que liberou.

Depois de uma semana de relatórios, pergunte uma vez ao dono se ele quer ligar,
mostrando o que teria sido apagado.
