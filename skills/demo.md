# Demo: palco, não bancada

Use quando houver uma versão no ar para o dono ou outras pessoas verem, ou quando
o dono pedir para montar, trocar, ligar ou desligar uma demo. A demo é uma versão
aprovada, servida de um lugar onde ninguém trabalha.

## O registro

Cada demo tem uma linha na seção "Demo" de `local/estado.md` e o detalhe em
`local/recursos.md`:

- projeto, commit ou artefato, pasta, portas e URL;
- como sobe e como desce, e a checagem de saúde com o percurso principal;
- estado desejado: `ligada` ou `desligada pelo dono` (com a data). Desligada pelo
  dono só volta quando ele pedir.

## Montar (trabalho para um intérprete)

Montar, trocar e desligar a demo são pedidos anotados, feitos por um intérprete.

1. **Pasta própria**, fora de qualquer worktree de chat, por exemplo
   `~/maestro-demo/<projeto>/<commit curto>`. Prefira copiar o commit sem `.git`
   (`git archive <commit> | tar -x -C <pasta>`), para ninguém poder trocar de
   branch lá. `git worktree lock` impede remover a pasta, mas não impede editar.
2. **Commit fixo e build de produção** quando der. Servidor de desenvolvimento só
   se não houver outro jeito, e isso fica registrado.
3. **Processo fora de qualquer chat.** No macOS, um LaunchAgent do usuário
   (launchd), com `KeepAlive` e log em arquivo; no Linux, `systemd --user`. Uma ação
   de projeto do T3 serve como caminho simples, se rodar num terminal do T3 e não no
   shell do agente. `nohup` ou `&` no shell do agente não bastam: o processo pode
   morrer junto com a sessão.
4. **Dados fictícios** e banco próprio da demo.
5. **Prova:** checagem de saúde e percurso principal conferidos, com hora e commit.

## Trocar de versão (só a pedido do dono)

1. Build da candidata em pasta nova, de commit fixo.
2. Ela sobe numa porta temporária e passa na saúde e no percurso principal.
3. Troca: desce a atual, sobe a nova na porta da demo e confere de novo.
4. A anterior fica guardada para voltar. Apagá-la é exclusão: pede o dono.

## Desligar

Pedido do dono: o intérprete desliga (no macOS, `launchctl bootout` do LaunchAgent) e
você registra "desligada pelo dono, <data>" no índice, na retomada e nas decisões
da pauta. Ninguém religa sem ele pedir, nem a rotina, nem um intérprete.

## Rotina

Com estado desejado `ligada`, a `T3 Monitor` confere a saúde a cada rodada. Caiu:
avise com o erro exato. Não religue além do que o supervisor já faz sozinho.

## Cláusula intocável

Vai em todo pedido a um intérprete, na seção "Demo" de `mensagem-filho.md`:

```
A demo de <projeto> fica em <pasta>, portas <portas>. Ela é intocável: não edite
nada lá, não rode git, testes ou builds lá, não pare nem reinicie os processos
dela e não use essas portas. Nunca reverta código nem rode teste que você espera
ver falhar numa pasta que esteja servindo alguém. Processos que você subir ficam
na sua sessão, e você os desliga ao terminar.
```

Sem demo registrada, use só as duas últimas frases.

## Antes de ligar a limpeza do T3

A limpeza automática de worktrees do T3 e o assentar de chats podem levar junto o
que roda dentro de uma worktree de chat. Recomende ligá-la só depois que nenhuma
demo morar em worktree de chat. Veja `recursos.md`.
