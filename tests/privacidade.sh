#!/usr/bin/env bash
# Confere a checagem de privacidade numa cópia temporária do repositório, com
# termos fictícios: grafias equivalentes, termo dentro de palavra, termo com
# hífen ou sublinhado, frases e um texto limpo.
#
#   bash tests/privacidade.sh
set -euo pipefail
unset CDPATH

FONTE="$(cd -- "$(dirname -- "$0")/.." >/dev/null && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=teste GIT_AUTHOR_EMAIL=teste GIT_COMMITTER_NAME=teste GIT_COMMITTER_EMAIL=teste
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
# Sem manutenção automática do git em segundo plano: ela reempacota objetos no
# meio de um clone e torna o teste instável.
export GIT_CONFIG_COUNT=3 GIT_CONFIG_KEY_0=gc.auto GIT_CONFIG_VALUE_0=0 \
  GIT_CONFIG_KEY_1=maintenance.auto GIT_CONFIG_VALUE_1=false \
  GIT_CONFIG_KEY_2=gc.autoDetach GIT_CONFIG_VALUE_2=false
falhas=0
ok() { echo "  ok: $1"; }
falha() { echo "  FALHOU: $1"; falhas=$((falhas + 1)); }

C="$TMP/copia"
mkdir -p "$C"
(cd "$FONTE" && git ls-files -z --cached --others --exclude-standard |
  while IFS= read -r -d '' f; do [ -f "$f" ] && printf '%s\0' "$f"; done |
  tar --null -T - -cf -) | (cd "$C" && tar -xf -)
(cd "$C" && git init -q && git add -A && git commit -qm copia)

# Termo fictício na lista da base; dono e termos privados fictícios.
(cd "$C" && bash scripts/checar-privacidade.sh --hash "Íris" >> .github/termos-proibidos.sha256)
mkdir -p "$C/local"
printf -- '- **Dono:** Pessoa Fictícia\n' > "$C/local/config.md"
printf 'segredo-revisor\nAlfa Beta\n' > "$C/local/termos-privados.txt"

nfd="$(printf 'I\xcc\x81ris')"   # Í escrito como I + acento combinante
recusa() { # descrição, texto
  printf '%s\n' "$2" > "$C/texto.txt"
  if (cd "$C" && bash scripts/checar-privacidade.sh --arquivo texto.txt) >/dev/null 2>&1; then
    falha "recusa $1"
  else
    ok "recusa $1"
  fi
}
aceita() { # descrição, texto
  printf '%s\n' "$2" > "$C/texto.txt"
  if (cd "$C" && bash scripts/checar-privacidade.sh --arquivo texto.txt) >/dev/null 2>&1; then
    ok "aceita $1"
  else
    falha "aceita $1"
  fi
}

echo "Termos da base"
recusa "o termo como foi cadastrado" "Falei com Íris hoje."
recusa "minúsculas" "falei com íris"
recusa "maiúsculas" "FALEI COM ÍRIS"
recusa "sem acento" "falei com iris"
recusa "acento combinante (NFD)" "falei com $nfd"
recusa "termo dentro de palavra" "prefixoÍrissufixo"
recusa "termo entre sublinhados" "prefixo_Íris_sufixo"
recusa "termo entre hífens" "prefixo-Íris-sufixo"
recusa "termo entre parênteses" "(Íris)"
aceita "texto sem termo" "Uma linha limpa, com pedido, prova e merge."

echo "Termos privados desta cópia"
recusa "termo com hífen" "o segredo-revisor apareceu"
recusa "termo com hífen escrito junto" "o segredorevisor apareceu"
recusa "frase de duas palavras" "falei com Alfa Beta ontem"
recusa "nome do dono" "Pessoa Fictícia pediu"
recusa "uma palavra do nome do dono" "a pessoa pediu"
aceita "palavras soltas da frase em lugares diferentes" "alfa de um lado, beta do outro"

echo "Checagem do repositório"
printf 'Texto com %s.\n' "$nfd" > "$C/docs/nota.md"
(cd "$C" && git add docs/nota.md)
if (cd "$C" && bash scripts/checar-privacidade.sh) >/dev/null 2>&1; then
  falha "recusa termo em NFD num arquivo versionado"
else
  ok "recusa termo em NFD num arquivo versionado"
fi

echo
if [ "$falhas" -eq 0 ]; then echo "Todos os casos passaram."; else echo "$falhas caso(s) falharam."; exit 1; fi
