# Referências para versões, changelog e regras enxutas

19/11/2026. Só fontes abertas nesta pesquisa. Serviu de base para a regra de
versões do `CHANGELOG.md` e para o enxugamento das regras.

## 1. T3 Code

**O que faz.**

- Versões `0.x`: só o último número anda. Tudo o que saiu desde a v0.1.0, de
  15/10 a 17/11, foram 11 estáveis, todas patch (0.1.0 → 0.1.10), mais de três
  nightlies por dia
  ([lista de versões](https://github.com/pingdotgg/t3code/releases)).
- A estável é o build da última nightly: só sai o que quem testa já rodou
  ([release.yml](https://github.com/pingdotgg/t3code/blob/main/.github/workflows/release.yml)).
- Não há `CHANGELOG.md`. As notas saem de um script com a regra "até 7 itens",
  "um nome curto e uma frase de no máximo 20 palavras", "diga o que a pessoa pode
  fazer", "sem título, introdução ou números de PR", e "sete é teto; pare quando
  acabarem, mesmo que dê zero"
  ([generate-release-notes.ts](https://github.com/pingdotgg/t3code/blob/main/scripts/generate-release-notes.ts)).
  O resto vira "Plus N more bug fixes", com a lista completa recolhida
  ([v0.1.10](https://github.com/pingdotgg/t3code/releases/tag/v0.1.10)).
- Regras para agentes: `CLAUDE.md` com uma linha (`@AGENTS.md`) e um `AGENTS.md`
  de 216 linhas, que se chama de "bons padrões" mais que de "regras duras"
  ([AGENTS.md](https://github.com/pingdotgg/t3code/blob/main/AGENTS.md)). Um job
  do CI barra o PR que aumenta o contexto dos agentes sem a etiqueta de um
  mantenedor
  ([agent-context-budget.yml](https://github.com/pingdotgg/t3code/blob/main/.github/workflows/agent-context-budget.yml)).

**O que copiar.** Poucos itens por versão, escritos pelo que a pessoa ganha. O
número que pouco anda. Um teto de tamanho para as regras, conferido no CI.

**O que não serve.** Nightlies e notas geradas por modelo: aqui sai uma versão
por semana, escrita à mão. O ritmo de duas estáveis por semana também não: cada
versão com regra nova pede o ok do dono.

## 2. Conductor

**O que faz.** Cada versão tem número, data e um título em palavras simples
("Know what you're spending", "Conductor is back"), um ou dois parágrafos para
quem usa e, quando precisa, as seções Improvements, Fixes e Misc. Conserto
pequeno vira "New in 0.94.2" dentro da versão de origem. Uma versão pode ter uma
linha só (0.95.1). Quando muda um padrão, diz como voltar ("Turn them back on
with Settings…"). Ritmo de mais ou menos uma por semana
([changelog](https://www.conductor.build/changelog)).

**O que copiar.** O título por versão, a frase que começa pelo que a pessoa pode
fazer e o "como voltar".

**O que não serve.** Imagens e listas longas de consertos.

## 3. Ecossistema T3

**O que faz.** create-t3-app, t3-env e uploadthing usam changesets: um arquivo
por mudança diz se ela é patch, minor ou major, e o changelog de cada pacote sai
gerado, com PR e autor por linha
([.changeset do create-t3-app](https://github.com/t3-oss/create-t3-app/tree/main/.changeset),
[cli/CHANGELOG.md](https://github.com/t3-oss/create-t3-app/blob/main/cli/CHANGELOG.md)).
O t3-env tem uma regra de Cursor genérica
([general.mdc](https://github.com/t3-oss/t3-env/blob/main/.cursor/rules/general.mdc)).

**O que copiar.** Só a ideia: quem muda diz se a mudança vale patch, minor ou
major. Aqui isso é a linha em "Próxima versão".

**O que não serve.** Changesets é feito para pacotes npm. As regras de agente
desses repositórios não trazem nada que sirva.

## 4. "Potato / Laura": poteto, Lauren Tan

**Confirmado.** O perfil [@poteto](https://github.com/poteto) diz "lauren",
engenheira na xAI e no time do React Compiler.

**O que faz.**

- [noodle](https://github.com/poteto/noodle) ("Orchestrate agents using skills")
  é o mais parecido com o maestro: `VERSION`, `CHANGELOG.md` por versão com data e
  link de comparação, e um
  [CLAUDE.md](https://github.com/poteto/noodle/blob/main/CLAUDE.md) de 28 linhas
  em itens curtos com rótulo em negrito. As seis versões, de v0.1.0 a v0.1.5,
  saíram em pouco mais de 24 horas
  ([versões](https://github.com/poteto/noodle/releases)).
- [brainmaxxing](https://github.com/poteto/brainmaxxing) (memória persistente e
  melhoria de skills): `CLAUDE.md` de 8 linhas, skills curtas com as palavras que
  as disparam, e o README diz que só o `/reflect` já dá a maior parte do valor.
- [verification-skill-example](https://github.com/poteto/verification-skill-example):
  "agentes pagam por cada token que releem"; cada entrada é curta.

**O que copiar.** Arquivo principal curto, detalhe nas skills, e o lembrete de
que cada linha de regra custa a cada conversa.

**O que não serve.** O changelog gerado de mensagens de commit e as várias
versões num dia, o mesmo problema que o maestro tem.

Não achei texto público dela sobre agentes fora desses repositórios: o
[poteto.github.io](https://github.com/poteto/poteto.github.io) só tem o README.

## Por que o sistema anterior era ruim

1. Duas versões (2.0.0 e 2.1.0) em dois dias, porque cada PR mudava o `VERSION`
   (README, "For maintainers", passo 3). Cada versão com regra pede o ok do dono,
   então versão rápida vira pergunta frequente.
2. O changelog tinha 140 linhas para duas versões, em dois idiomas, no formato de
   lista técnica (Adicionado, Mudou, Corrigido). O T3 limita a 7 itens e o
   Conductor escreve para quem usa.
3. Faltava uma regra do que muda o número e do que não muda.
