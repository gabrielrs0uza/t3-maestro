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

- Versões mais lentas: o número só muda quando sai uma versão, no máximo uma por
  semana, com a regra acima. Este arquivo ficou curto e só em português.
- Menos mensagens: as rotinas padrão são só a atualização diária e o resumo das
  18:00, e nenhuma escreve sem novidade. Vigia de 30 minutos, faxina e Linear
  viram opcionais, desligados; para religar, peça ao maestro.
- Sem cerimônia: nada de "Anotei" nem rodapé de pedidos nas respostas. O índice
  perde a tabela de chats, que a barra lateral do T3 já mostra.
- Regras mais curtas: o `AGENTS.md` foi de 590 para cerca de 440 linhas, sem
  mexer nas travas.

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
