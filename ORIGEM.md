# Origem

De onde vêm as ideias deste repositório, só com o que dá para conferir.

## A cadeia

pstack → pstack-t3 → t3-maestro → as cópias de cada pessoa.

| Elo | Onde | Como conferir |
|---|---|---|
| pstack | `cursor/plugins`, pasta `pstack`, licença MIT | O aviso de licença em `skills/LICENSE` |
| pstack-t3 | `creedants/pstack-t3`, licença MIT; porta o pstack para o T3 Code e fixa a versão de origem em `upstream.json` | O aviso "pstack-t3 adaptations" em `skills/LICENSE` e o commit `0957c82` deste repositório, que tirou do README o crédito com o link do pstack-t3 e manteve a licença |
| t3-maestro | este repositório | `CHANGELOG.md` |

O aviso de licença exigido pelo MIT fica em `skills/LICENSE`, sem mudança.

## As skills

Correspondência por nome com as skills do pstack-t3. Todas foram reescritas em
português e adaptadas ao maestro; não são cópias.

| Skill daqui | No pstack-t3 | Como se sabe |
|---|---|---|
| `arena`, `blast-radius`, `correct`, `interrogate`, `ketchup`, `reflect` | skill de mesmo nome | mesmo nome e licença |
| `roteiros` | playbooks do `poteto-mode` | o texto anterior ao commit `0957c82` dizia "Adaptado dos playbooks do pstack-t3" |
| `principios` | skills `principle-*` | o texto anterior ao commit `0957c82` dizia "Adaptado do pstack-t3" |
| `explicar`, `painel`, `pedidos`, `paralelo`, `mensagem-filho`, `demo`, `recursos`, `faxina`, `atualizar`, `sugerir`, `primeira-conversa` | não há | escritas aqui |

## Ideias trazidas na versão 2.0.0

A versão 2.0.0 trouxe ideias, não código, da skill `brigade` do pstack-t3, lida no
commit `dd15e63` (versão 0.10.0, de 07/11/2026), cujo `upstream.json` fixa o pstack
0.15.36 no commit `c742dd6`:

- registro de pedidos separado das unidades de trabalho, com o coordenador como
  único escritor;
- decisões do dono levantadas uma vez, com um padrão, e o resto do trabalho
  seguindo em volta delas;
- arquivo de retomada reescrito antes de a conversa ser resumida e relido depois;
- "relatório pronto sem aviso" tratado como defeito, e uma única cutucada para o
  intérprete parado;
- limite de três devoluções de revisão antes de virar decisão do dono;
- apagar só o que o próprio trabalho criou.

## Ideias trazidas na versão 2.4.0

Ideias, não texto, do "coordinator skill" do Copybook
([copybook.page](https://copybook.page/t/coordinator-skill-for-claude-code-and-codex)),
pasta `standalone/coordinator` de `Heyvhuang/copybook-skills`, lida no commit
`7efd216` (26/11/2026). A pasta é MIT (VOXYZ LABS LTD); o texto das skills do
repositório é CC BY 4.0. Tudo foi reescrito em português; nada foi copiado.

- pacote de decisões, da "release packet" e da "morning list";
- área de cada frente no pedido, conferida na volta;
- revisão que começa pelo veredito, com a lista do que bloqueia;
- conferir se uma branch carrega outra que espera o dono;
- referências e prints do dono levados como vieram;
- ligar cada PR ao chat que o abriu, e ler a atividade de chat parado.

Também na 2.4.0, da mesma fonte: a lição "vagas, não limite de carga" do
`heavy.sh`, que virou um contador só de leitura (`scripts/pesados.sh`, escrito
aqui); o caderno de lições, do `lessons.md`; e a apresentação conjunta dos PRs
prontos, sem a publicação em lote por autorização geral.

## O que não está registrado

A versão exata do pstack-t3 usada na primeira adaptação das skills não ficou
registrada no histórico. Ao comparar de novo, anote aqui o commit lido.
