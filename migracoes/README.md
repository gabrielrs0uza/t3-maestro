# Migrações

Cada arquivo `NNN-nome.txt` leva a pasta `local/` de um formato para o seguinte.
O `scripts/maestro.sh atualizar` aplica, em ordem, as de número maior que o
"Formato local" de `local/versao.md`, depois de um backup em `local/backups/`, e
grava o número de cada uma que terminou.

As migrações são declarativas: o script instalado lê cada linha e só conhece estas
operações, com campos separados por ` | `:

| Operação | O que faz |
|---|---|
| `pasta \| local/x` | Cria a pasta dentro de `local/`. |
| `mover \| arquivo \| local/x` | Move um arquivo comum, solto na raiz e fora do git, para `local/`. Se o destino existir igual, guarda o da raiz em `local/arquivo/`; se existir diferente, para sem mexer. |
| `arquivar \| arquivo \| local/x` | Move um arquivo comum da raiz para `local/`, com nome novo se o destino existir. |
| `criar-estado` | Cria o índice vazio em `local/estado.md`, se faltar. |
| `campo \| Nome \| valor` | Acrescenta ao `local/config.md` um campo da lista fechada do script, se ele ainda não existir, com um valor aceito para aquele campo. |
| `tarefa \| CÓDIGO` | Pede ao maestro uma tarefa da lista fechada de códigos, descrita em `skills/atualizar.md`. |

Linhas vazias e as que começam com `#` são ignoradas. A versão inteira é recusada
antes do merge se uma migração tiver nome fora de `NNN-nome.txt`, operação
desconhecida, caminho fora de `local/`, link simbólico em qualquer parte do
caminho, origem que não seja arquivo comum, campo fora da lista ou valor não
aceito, ou código de tarefa desconhecido. Uma versão com migração nova sempre pede
a confirmação do dono.

Regras para escrever uma migração:

- Pode rodar de novo, inteira ou depois de parar no meio, sem duplicar nada.
- Nunca apaga nem sobrescreve um arquivo de `local/`: acrescenta, ou move para
  `local/arquivo/`.
- Nunca muda um valor que a pessoa escreveu e mantém campos que não conhece.
- O que pede julgamento vira uma `tarefa` com código da lista fechada.
- Entra com um cenário em `tests/atualizacao.sh`.
- Operação, campo ou código novo exige mudar o script, e a versão que muda o script
  pede a confirmação do dono.
