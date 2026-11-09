#!/usr/bin/env bash
# Falha se um arquivo versionado tiver caminho de máquina, ID de chat, e-mail,
# credencial ou um termo de .github/termos-proibidos.txt.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ignorados=(
  ':!LICENSE'
  ':!skills/LICENSE'
  ':!.github/termos-proibidos.txt'
  ':!scripts/checar-privacidade.sh'
)

padroes='/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+/|mcp:launch:[0-9a-f]{16,}'
padroes+='|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}'
padroes+='|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}'

falhou=0

if git grep -n -I -E "$padroes" -- . "${ignorados[@]}"; then
  falhou=1
fi

if git grep -n -I -E -f .github/termos-proibidos.txt -- . "${ignorados[@]}"; then
  falhou=1
fi

if [ "$falhou" -ne 0 ]; then
  echo "Dados pessoais ou específicos encontrados nos arquivos acima." >&2
  exit 1
fi

echo "Nenhum dado pessoal encontrado."
