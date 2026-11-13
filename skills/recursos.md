# Recursos: recibo e ciclo de vida

Use ao receber o aviso de um intérprete, ao encerrar um chat e na `faxina`. Todo
recurso criado por um chat tem dono, lugar e destino registrados.

## O recibo

Todo aviso de intérprete termina com a linha "Recursos", no modelo de
`mensagem-filho.md`:

- worktree: caminho, branch, se está limpa, commits sem push;
- portas e processos: PID, hora de início e comando (o PID sozinho se repete);
- containers: ID, etiquetas e volumes;
- remotos: cópia de banco na nuvem, deploy de prévia, máquina remota;
- pastas grandes e provas que só existem ali.

## O inventário: `local/recursos.md`

Uma linha por recurso, mantida por você:

| Recurso | Tipo | Onde | Dono | Criado em | Situação |
|---|---|---|---|---|---|
| worktree da Fila B | worktree | <caminho> | Fila B | 13/11 15:02 | em uso |
| servidor da Fila B | processo 4312, 17:20, `pnpm dev` | porta 3150 | Fila B | 13/11 17:20 | em uso |

Situação: `em uso`, `liberar`, `liberado` (com a prova) ou `retido: <motivo>`.
Recurso usado por mais de um chat não é do último que usou: anote todos.

## Encerrar, liberar e arquivar

São três passos, nessa ordem, cada um com sua marca:

1. **Encerrar:** a entrega está fechada. O pedido foi conferido, o PR entrou, o
   dono validou ou desistiu. Marque o chat `encerrado` e os pedidos.
2. **Liberar:** mande o intérprete:
   - confirmar que a entrega está salva no destino combinado;
   - exportar as provas: scripts, saídas e prints vão para a resposta final, ou
     para a "Pasta de provas" do config se forem grandes;
   - desligar servidores, containers e bancos locais que ele criou;
   - conferir trabalho sem salvar: `git status`, commits sem push, arquivos não
     rastreados e arquivos ignorados que importam, como `.env`;
   - remover a worktree dele, sem `--force`;
   - mandar o recibo do que liberou e do que reteve, com o motivo.

   Se algo não estiver salvo, ele não apaga e pergunta. Nada que ele não criou.
   Confira o recibo com a prova "limpo" e atualize `local/recursos.md`.
3. **Arquivar:** só depois do recibo, use `t3_thread_organize` com `settle` ou
   `archive`. Arquivar limpa a lista de chats; não libera disco.

## Casos difíceis

- **Revisor:** as reproduções ficam na worktree dele. Antes de removê-la, elas
  precisam estar na resposta final ou na pasta de provas. Se a prova depender da
  worktree (dependências, banco local), a worktree fica `retido` até o dono decidir.
- **Intérprete que falhou ou sumiu sem recibo:** monte o inventário pelo que está
  registrado e pela `faxina` e leve ao dono. Limpar o que ficou pede a aprovação
  dele, a menos que ele mande retomar aquele chat para fazer a liberação.
- **Recurso remoto:** entra no inventário como qualquer outro. Desligar ou apagar
  pede o dono, mesmo que o próprio intérprete o tenha criado: a exceção de limpeza ao
  encerrar vale só para o que está na máquina.

## A limpeza do próprio T3

O T3 tem limpeza de worktrees (Settings → Worktrees → Cleanup), que vem desligada,
e ações de projeto com `stopOnSettle` e `runOnSettle`. Ligar é decisão do dono, no
app. Recomende só depois que nenhuma demo morar em worktree de chat, com "Keep
worktrees with local changes" em "Any local files". Não use `runOnSettle` para
apagar caches: ele pode rodar com comandos ativos na worktree.

A limpeza do T3 não cobre tudo: worktree com branch renomeada, worktree
compartilhada, worktree sem chat e a pasta de rascunhos. A `faxina` relata essas.
