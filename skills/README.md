# Skills do chat mestre

Adaptadas ao fluxo deste chat a partir do `pstack-t3`
(https://github.com/creedants/pstack-t3), com licença MIT:
Copyright (c) 2026 Lauren Tan; Copyright (c) 2026 Marcus Gibson.

As originais dependem de `pstack-runtime`, `roles.py` e `delegate_task`. Estas não
dependem de nada disso e abrem chats com `t3_thread_launch`, como manda o
`AGENTS.md`. Quando houver conflito, o `AGENTS.md` vence.

Nada aqui autoriza merge, deploy, alteração em produção ou exclusão.

Para usar num chat filho, cite no `message` o caminho absoluto do arquivo, porque
o filho não vê esta pasta por conta própria:
`<pasta do mestre>/skills/<nome>.md`.
