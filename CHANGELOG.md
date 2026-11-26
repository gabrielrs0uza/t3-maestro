# Mudanças

O que muda para quem usa o maestro, versão por versão, em poucas linhas. O
maestro lê este arquivo ao atualizar e conta ao dono, no idioma dele, com as
próprias palavras.

## Como os números mudam

- Muda só quando sai uma versão, no máximo uma por semana. Merge na `main` não
  muda: o que entra espera em "Próxima versão", sempre no topo.
- **X** (3.0): a pessoa precisa agir à mão, ou `local/` muda sem migração automática.
- **Y** (2.2): comportamento novo ou diferente. Ex.: o resumo passa a citar chats parados.
- **Z** (2.1.1): conserto é sempre Z, mesmo tocando script, regra ou skill, se não
  muda o que o maestro faz quando tudo funciona. Ex.: o atualizador falhava com
  espaço no caminho.
- Não muda o número: README, `docs/`, testes, CI e texto sem efeito.
- Tag sempre `vX.Y.Z`, igual ao `VERSION`: o único formato que as cópias aceitam.
- Toda versão que não for só documentação pede o ok do dono ao atualizar.

Cada versão tem um título curto, uma frase do que muda e, no máximo, cinco itens,
escritos pelo que a pessoa ganha. O que pede ação de quem já usa vem primeiro; se
um padrão mudou, diga como voltar. Detalhe técnico fica nos PRs e em `docs/`. Por
quê: [docs/referencias-2026-11.md](docs/referencias-2026-11.md).

## Próxima versão

## [2.4.0] - 2026-11-26 · Tudo o que espera você, junto

O maestro junta o que depende de você e confere melhor o que volta dos chats e o
que pesa na máquina. Sai um dia depois da 2.3.0, exceção única pedida pelo
mantenedor; a regra de uma versão por semana continua.

- Muda regra e script: pede o seu ok ao atualizar. Tetos: regras 455 linhas,
  skills 1660.
- O que espera o seu sim chega junto, num pacote: no resumo, quando você pede ou
  quando juntam três, cada item com recomendação e se dá para desfazer. PRs
  prontos vêm juntos, mas o sim é por PR.
- Cada frente diz em que arquivos mexe, e o maestro confere na volta; prints e
  exemplos seus chegam ao chat como vieram.
- A revisão começa dizendo se pode ou não entrar; só o que bloqueia volta para
  correção. Antes de um merge, o maestro diz se o PR carrega outro.
- Antes de dar a vaga pesada, o maestro olha o que está ligado em cada chat e,
  acima do limite, pede para desligar. Caderno de lições, com prazo para sair.

## [2.3.0] - 2026-11-25 · Lista mais limpa

A lista de chats mostra só o que espera você, e o maestro passa a conhecer todas
as ferramentas do T3.

- Muda regra: pede o seu ok ao atualizar.
- Chat que terminou sem nada para você sai sozinho da lista de ativos; o que
  espera você (pergunta, falha, tela para validar, PR para aprovar) continua à
  vista.
- O maestro ganha um guia de todas as ferramentas do T3, do que cada uma faz e
  quando usar; o que apaga ou desliga continua pedindo o seu ok.

## [2.2.0] - 2026-11-19 · Menos mensagens

O maestro fala menos, sem cerimônia, e as versões passam a sair mais devagar.

- Muda regra: pede o seu ok ao atualizar.
- Suas rotinas continuam como estão; o maestro pergunta uma vez se quer desligar
  vigia, faxina ou Linear, que deixaram de ser padrão. Instalação nova fica só com
  a atualização diária e o resumo das 18:00, calados quando não há novidade.
- Sem "Anotei" nem rodapé de pedidos nas respostas; o índice perde a tabela de
  chats, que a barra lateral do T3 já mostra.
- Versões mais lentas: o número só muda quando sai uma versão, no máximo uma por
  semana.
- Regras mais curtas: o `AGENTS.md` foi de 590 para 442 linhas, sem mexer nas
  travas.

## [2.1.0] - 2026-11-14 · Mensagens curtas

O maestro passa a escrever curto e simples: começa pela resposta, sem jargão, só
o que mudou e no máximo uma pergunta por mensagem.

- Muda regra: pede o seu ok ao atualizar.
- Nada muda no seu config. Para mensagens mais explicadas, "Estilo: detalhado".

## [2.0.0] - 2026-11-13 · Atualização sozinha

Primeira versão com número e atualização sozinha.

- Uma vez só: peça ao maestro para rodar `git pull --ff-only` na pasta dele e
  reler o `AGENTS.md`. Depois disso, ele confere as versões novas uma vez por dia,
  aplica sozinho só documentação e pede o seu ok para o resto.
- Seus arquivos vão para `local/`, com backup: `config.local.md` vira
  `local/config.md`; o `estado.md` antigo fica em `local/arquivo/`.
- O config ganha campos novos com valor padrão; os seus valores não mudam. O
  maestro pergunta uma vez se pode abrir chats sozinho.
- Novos: lista de pedidos, prova antes de dizer "pronto", chats em paralelo com
  uma tarefa pesada por vez, demo protegida e faxina que só relata.
- Dá para voltar à versão anterior a qualquer momento.

## [1.x] - 2026-11-09

Versão sem número, até o commit `f947c1e`.
