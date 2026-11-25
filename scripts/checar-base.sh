#!/usr/bin/env bash
# Confere que a base está coerente antes de uma versão sair: VERSION com entrada
# no CHANGELOG, bloco fixo marcado uma vez, skills citadas existentes, migrações
# em sequência e scripts sem erro de sintaxe.
set -euo pipefail
unset CDPATH
cd -- "$(git rev-parse --show-toplevel)"
falhou=0
erro() { echo "ERRO: $1" >&2; falhou=1; }

versao="$(tr -d '[:space:]' < VERSION)"
printf '%s\n' "$versao" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$' || erro "VERSION inválida: $versao"
grep -qF "## [$versao]" CHANGELOG.md || erro "CHANGELOG.md não tem a entrada ## [$versao]"
# Cada versão no CHANGELOG fica curta: até 5 itens e 14 linhas com texto.
longas="$(awk '
  /^## \[/ { if (v != "") print v, itens, linhas; v = $2; itens = 0; linhas = 0; next }
  /^##? / { if (v != "") print v, itens, linhas; v = ""; next }
  v != "" && /^- / { itens++ }
  v != "" && NF { linhas++ }
  END { if (v != "") print v, itens, linhas }' CHANGELOG.md | awk '$2 > 5 || $3 > 14 { print $1 }')"
[ -z "$longas" ] || erro "CHANGELOG.md: versões longas demais (até 5 itens e 14 linhas): $(echo $longas)"
# Orçamento de contexto, como o do T3 Code: as regras não crescem sem alguém
# decidir. Subir estes números é uma decisão do PR, escrita no CHANGELOG.
[ "$(wc -l < AGENTS.md)" -le 450 ] || erro "AGENTS.md passou de 450 linhas; enxugue ou suba o teto aqui, com motivo"
[ "$(cat skills/*.md | wc -l)" -le 1550 ] || erro "skills/ passou de 1550 linhas; enxugue ou suba o teto aqui, com motivo" # 1550: ferramentas-t3 é guia de consulta, não regra lida a cada turno
for leia in README*.md; do
  grep -qE "badge/(version|vers%C3%A3o)-$versao-" "$leia" || erro "o selo de versão de $leia não diz $versao"
done

ini="$(grep -n '<!-- fixo:inicio -->' AGENTS.md | cut -d: -f1 | tr '\n' ' ')"
fim="$(grep -n '<!-- fixo:fim -->' AGENTS.md | cut -d: -f1 | tr '\n' ' ')"
if [ "$(echo $ini | wc -w)" -ne 1 ] || [ "$(echo $fim | wc -w)" -ne 1 ] || [ "${ini% }" -ge "${fim% }" ]; then
  erro "AGENTS.md precisa de um bloco fixo só, com início antes do fim"
fi
grep -qx '@AGENTS.md' CLAUDE.md || erro "CLAUDE.md precisa importar o AGENTS.md"

for s in $(grep -ohE 'skills/[a-z0-9-]+\.md' AGENTS.md README.md skills/*.md | sort -u); do
  [ -f "$s" ] || erro "$s é citada mas não existe"
done

. scripts/lib-maestro.sh
n=0
# shellcheck disable=SC2010 # nomes da base; o regex abaixo e o NOME_MIGRACAO recusam os estranhos
for m in $(ls migracoes | grep -E '^[0-9]{3}-.*\.txt$' | sort); do
  n=$((n + 1))
  [ "$((10#$(echo "$m" | cut -c1-3)))" -eq "$n" ] || erro "migração fora de sequência: $m"
  migracao validar "$(echo "$m" | cut -c1-3)" "migracoes/$m" >/dev/null || erro "migração inválida: $m"
done
# shellcheck disable=SC2010 # aqui o ls | grep serve justamente para achar nome fora do padrão
[ -z "$(ls migracoes | grep -vE '^([0-9]{3}-.*\.txt|README\.md)$' || true)" ] || erro "migracoes/ só aceita NNN-nome.txt e README.md"

for f in scripts/*.sh tests/*.sh; do
  bash -n "$f" || erro "erro de sintaxe em $f"
done

git check-ignore -q local/config.md || erro "local/ precisa estar no .gitignore"

[ "$falhou" -eq 0 ] && echo "Base coerente: versão $versao."
exit "$falhou"
