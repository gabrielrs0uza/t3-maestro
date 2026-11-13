#!/usr/bin/env bash
# Versão, migração e atualização do maestro. Rode da pasta do mestre:
#
#   scripts/maestro.sh estado
#   scripts/maestro.sh iniciar
#   scripts/maestro.sh atualizar [--auto] [--aceitar vX.Y.Z] [--aceitar-origem]
#   scripts/maestro.sh voltar local/backups/<pasta>
#   scripts/maestro.sh novidades <de> <para>
#
# A saída termina com "RESULTADO: ...", que o mestre lê para saber o que fazer
# (veja skills/atualizar.md). Nada da pessoa é apagado: o que muda de lugar vai
# para local/arquivo/ ou local/backups/.
#
# A conferência de uma versão nova é feita por este script, o que já está
# instalado, antes de qualquer merge. Ela só deixa entrar sozinha uma versão que
# muda apenas documentação; o resto espera a confirmação do dono. Migrações são
# declarativas e interpretadas por este script.
set -euo pipefail
unset CDPATH

RAIZ="$(cd -- "$(dirname -- "$0")/.." >/dev/null && pwd -P)"
cd -- "$RAIZ"
. "$RAIZ/scripts/lib-maestro.sh"
export MAESTRO_PID=$$
# Atributos neutros: nenhum arquivo de atributos do sistema ou do usuário muda o
# que o diff mostra ou o que o merge grava (filtros, textconv, -diff, LFS). Os
# .gitattributes e .lfsconfig de uma versão nova são recusados em escolher_alvo.
export GIT_ATTR_NOSYSTEM=1
unset GIT_EXTERNAL_DIFF
neutro="${GIT_CONFIG_COUNT:-0}"
case "$neutro" in ''|*[!0-9]*) neutro=0 ;; esac
export "GIT_CONFIG_KEY_$neutro=core.attributesFile" "GIT_CONFIG_VALUE_$neutro=/dev/null"
export GIT_CONFIG_COUNT=$((neutro + 1))

LOCAL=local
CONFIG=$LOCAL/config.md
VERSAO=$LOCAL/versao.md
TRAVA=$LOCAL/.atualizando
# Nomes que uma versão pode trazer: só caracteres simples, e migrações no
# formato NNN-nome.txt. O resto torna a versão inválida antes do merge.
NOME_ARQUIVO='^[A-Za-z0-9._/-]+$'
NOME_MIGRACAO='^[0-9]{3}-[a-z0-9-]+\.txt$'
VOLTANDO=$LOCAL/.voltando

hoje() { date -u '+%Y-%m-%d'; }
agora() { date -u '+%Y-%m-%d %H:%M UTC'; }
carimbo() { date -u '+%Y%m%dT%H%M%SZ'; }

versao_base() {
  if [ -f VERSION ]; then tr -d '[:space:]' < VERSION; else echo "1.x"; fi
}

versao_registrada() {
  local v
  v="$(campo "$VERSAO" Base)"
  echo "${v:-1.x}"
}

formato_local() {
  local f
  f="$(campo "$VERSAO" "Formato local")"
  echo "${f:-0}"
}

ultima_migracao() {
  local n
  # shellcheck disable=SC2010 # só passam nomes do regex NOME_MIGRACAO, sem espaço nem símbolo
  n="$(ls migracoes 2>/dev/null | grep -E "$NOME_MIGRACAO" | sort | tail -1 | cut -c1-3 || true)"
  echo $((10#${n:-0}))
}

config_ativo() {
  if [ -f "$CONFIG" ]; then echo "$CONFIG"
  elif [ -f config.local.md ]; then echo config.local.md
  fi
}

preferencia() { # nome, padrão
  local arq v
  arq="$(config_ativo)"
  v=""
  [ -n "$arq" ] && v="$(campo_simples "$arq" "$1")"
  echo "${v:-$2}"
}

situacao() {
  if [ -f "$VOLTANDO" ]; then echo "voltar-pendente"
  elif [ -f "$CONFIG" ]; then
    if [ "$(formato_local)" -lt "$(ultima_migracao)" ]; then echo "migracao-pendente"
    else echo "em-dia"; fi
  elif [ -f config.local.md ]; then echo "antigo"
  elif [ -f "$VERSAO" ] || [ -n "$(ls -A "$LOCAL/backups" 2>/dev/null)" ]; then echo "sem-config"
  else echo "novo"
  fi
}

garantir_versao() {
  mkdir -p "$LOCAL"
  if [ ! -f "$VERSAO" ]; then
    printf '# Versão do maestro\n\nMantido por `scripts/maestro.sh`. Não edite à mão.\n\n' > "$VERSAO"
  fi
}

RETOMANDO=0
# Hora de início de um processo, para saber se um PID vivo ainda é o mesmo.
inicio_processo() { # pid
  { ps -o lstart= -p "$1" 2>/dev/null || true; } | sed 's/^ *//; s/ *$//'
}
# A trava só é tomada se o processo dono morreu ou se o PID dela passou a ser
# de outro processo; nunca por idade. Trava antiga, sem a hora de início, vale
# enquanto o PID estiver vivo.
travar() {
  mkdir -p "$LOCAL"
  if ! mkdir "$TRAVA" 2>/dev/null; then
    local pid inicio atual
    pid="$(cat "$TRAVA/pid" 2>/dev/null || true)"
    inicio="$(cat "$TRAVA/inicio" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      atual="$(inicio_processo "$pid")"
      if [ -z "$inicio" ] || [ -z "$atual" ] || [ "$inicio" = "$atual" ]; then
        echo "RESULTADO: ocupado (outra atualização está rodando, processo $pid)"
        exit 0
      fi
    fi
    echo "AVISO: uma atualização anterior foi interrompida; retomando de onde parou."
    RETOMANDO=1
  fi
  echo $$ > "$TRAVA/pid"
  inicio_processo $$ > "$TRAVA/inicio"
  trap 'rm -rf "$TRAVA"' EXIT
}

bloco_fixo() { # revisão
  { git show "$1:AGENTS.md" 2>/dev/null || true; } |
    awk '/<!-- fixo:inicio -->/ { f = 1 } f { print } /<!-- fixo:fim -->/ { f = 0 }'
  echo "--- CLAUDE.md"
  git show "$1:CLAUDE.md" 2>/dev/null || true
}

# Guarda tudo o que é local: local/ inteira, menos os próprios backups, e os
# arquivos da raiz que o git não acompanha (soltos ou ignorados).
fazer_backup() { # de, para
  local destino e
  destino="$(pasta_nova "$LOCAL/backups/$(carimbo)-$1-para-$2")"
  mkdir "$destino/local"
  for e in "$LOCAL"/* "$LOCAL"/.[!.]*; do
    [ -e "$e" ] || continue
    case "$(basename "$e")" in backups|.atualizando|.voltando) continue ;; esac
    cp -Rp "$e" "$destino/local/"
  done
  { git ls-files -z --others --exclude-standard; git ls-files -z --others --ignored --exclude-standard; } |
    while IFS= read -r -d '' e; do
      case "$e" in "$LOCAL"/*) continue ;; esac
      mkdir -p "$destino/raiz/$(dirname "$e")"
      cp -p "$e" "$destino/raiz/$e"
    done
  {
    echo "# Backup do maestro"
    echo
    echo "- **Criado em:** $(agora)"
    echo "- **Base registrada:** $(versao_registrada)"
    echo "- **Base no disco:** $(versao_base)"
    echo "- **Formato local:** $(formato_local)"
    echo "- **Commit:** $(git rev-parse HEAD)"
    echo
    echo "Para voltar: scripts/maestro.sh voltar $destino"
  } > "$destino/manifesto.md"
  echo "$destino"
}

# Lista o que muda de uma revisão para outra e não pode entrar sem o ok do dono:
# arquivos fora da lista de documentação, modo que não seja arquivo comum, migração
# declarativa inválida e o bloco fixo. Imprime uma linha por item.
mudancas_sensiveis() { # de, para
  local meta caminho modo status m
  while IFS= read -r -d '' meta && IFS= read -r -d '' caminho; do
    modo="$(echo "$meta" | cut -d' ' -f2)"
    status="${meta##* }"
    if [ "$status" != D ] && case "$caminho" in migracoes/[0-9]*.txt) true ;; *) false ;; esac; then
      if ! m="$(git show "$2:$caminho" | migracao validar "$(basename "$caminho" | cut -c1-3)" - 2>&1)"; then
        echo "$status $caminho (migração inválida: ${m#MIGRAÇÃO INVÁLIDA: })"
        continue
      fi
    fi
    if ! arquivo_de_documentacao "$caminho"; then
      echo "$status $caminho"
    elif [ "$status" != D ] && [ "$modo" != 100644 ]; then
      echo "$status $caminho (modo $modo)"
    fi
  done < <(git diff --raw -z --no-renames --no-abbrev "$1" "$2")
  if [ "$(bloco_fixo "$1")" != "$(bloco_fixo "$2")" ]; then
    echo "M AGENTS.md (bloco fixo)"
  fi
}

# Filtra, sem diferenciar maiúsculas, os caminhos que são da pessoa: tudo em
# local/ e os arquivos antigos da raiz. Num disco que não diferencia maiúsculas,
# "Local/x" grava em local/x.
caminhos_da_pessoa() {
  awk '{ c = tolower($0) } c ~ /^local\// || c == "config.local.md" || c == "estado.md"'
}

# Arquivos que mudam como o git mostra e grava os outros: .gitattributes (filter=,
# diff=, -diff) e .lfsconfig, em qualquer pasta e em qualquer caixa.
atributos_do_git() {
  awk '{ c = tolower($0); sub(/.*\//, "", c) } c == ".gitattributes" || c == ".lfsconfig"'
}

# Caminhos que a revisão passaria a guardar no git e que já existem aqui, fora
# do git (soltos ou ignorados). O merge os sobrescreveria.
colisoes_com() { # revisão
  local caminho
  while IFS= read -r -d '' caminho; do
    if [ -e "$caminho" ] || [ -L "$caminho" ]; then echo "$caminho"; fi
  done < <(git diff -z --name-only --no-renames --diff-filter=A HEAD "$1")
}

# Imprime os caminhos que mudam de uma revisão para outra e têm nome fora do
# padrão. Quebra de linha aparece como \n.
nomes_invalidos() { # de, para
  local caminho
  while IFS= read -r -d '' caminho; do
    if ! printf '%s' "$caminho" | LC_ALL=C grep -qE "$NOME_ARQUIVO" ||
       [ "$(printf '%s' "$caminho" | wc -l | tr -d ' ')" != 0 ]; then
      printf '%s\n' "$caminho" | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 } END { print "" }'
    elif case "$caminho" in migracoes/README.md) false ;; migracoes/*) true ;; *) false ;; esac &&
         ! basename "$caminho" | grep -qE "$NOME_MIGRACAO"; then
      echo "$caminho"
    fi
  done < <(git diff -z --name-only --no-renames "$1" "$2")
}

# Guarda o que uma versão pendente muda, para o dono ver antes de aceitar: a
# lista do que pede o ok, o diff do bloco fixo, se mudou, e o diff inteiro da
# versão em arquivo separado, sem cortes. O hash do diff entra na pendência, e o
# aceite só vale se o diff continuar o mesmo.
# Imprime os arquivos que a revisão muda e que poderiam enganar quem lê o diff:
# caracteres de controle (NUL, CR solto, ESC, os de C1, os bidi como U+202E, os de
# largura zero e o BOM) ou linhas com mais de 2000 bytes. Só tabulação e quebra
# de linha passam. As imagens de docs/assets ficam de fora.
com_controles() { # de, para
  local caminho motivo
  while IFS= read -r -d '' caminho; do
    case "$caminho" in docs/assets/*.png|docs/assets/*.jpg) continue ;; esac
    motivo="$(git cat-file -p "$2:$caminho" | LC_ALL=C perl -ne '
      if (/[\x00-\x08\x0B-\x1F\x7F]|\xC2[\x80-\x9F]|\xE2\x80[\x8B-\x8F\xAA-\xAE]|\xE2\x81[\xA0\xA6-\xA9]|\xEF\xBB\xBF|\xD8\x9C/) {
        print "caractere de controle na linha $."; exit;
      }
      my $linha = $_; $linha =~ s/\n\z//;
      if (length($linha) > 2000) { print "linha $. com mais de 2000 bytes"; exit; }' \
      || echo "não deu para conferir: falta o perl")"
    if [ -n "$motivo" ]; then echo "$caminho ($motivo)"; fi
  done < <(git diff -z --name-only --no-renames --diff-filter=AM "$1" "$2")
}

registrar_pendencia() { # tag, commit, de, lista
  local diff="$LOCAL/atualizacao-pendente.diff" linhas
  git diff --text --no-color --no-ext-diff --no-textconv "$3" "$2" > "$diff.tmp"
  mv "$diff.tmp" "$diff"
  linhas="$(wc -l < "$diff" | tr -d ' ')"
  {
    echo "# Atualização pendente: $1"
    echo
    echo "- **Tag:** $1"
    echo "- **Commit:** $2"
    echo "- **Diff completo:** $diff"
    echo "- **Linhas do diff:** $linhas"
    echo "- **Hash do diff:** $(git hash-object "$diff")"
    echo
    echo "Esta versão muda arquivos que pedem o ok do dono. Mostre a ele o resumo, a"
    echo "lista abaixo e o caminho do diff completo; só depois do ok dele:"
    echo
    echo "    scripts/maestro.sh atualizar --aceitar $1"
    echo
    echo "## O que pede o ok"
    echo
    printf '%s\n' "$4" | sed 's/^/- /'
    echo
    echo "## Tamanho de cada mudança"
    echo
    echo '```'
    git diff --text --stat=100 --no-color --no-ext-diff --no-textconv "$3" "$2"
    echo '```'
    if printf '%s\n' "$4" | grep -q '(bloco fixo)'; then
      echo
      echo "## Bloco fixo do AGENTS.md"
      echo
      echo '```diff'
      diff -u -L "bloco fixo atual" -L "bloco fixo de $1" <(bloco_fixo "$3") <(bloco_fixo "$2") || true
      echo '```'
    fi
    echo
    echo "O diff completo, com todas as $linhas linhas, está em $diff."
  } > "$LOCAL/atualizacao-pendente.md"
}

# Escolhe a versão alvo na origem. Define ALVO, ALVO_SHA, PENDENTE e BASE_MSG.
escolher_alvo() { # canal, remoto, aceito, auto, aceitar-origem
  local canal="$1" remoto="$2" aceito="$3" auto="$4" nova_origem="$5"
  local padrao saida atual tag sha pular url registrada base_ref sensiveis assinada colisoes invalidos
  ALVO=""; ALVO_SHA=""; PENDENTE=""; BASE_MSG=""
  if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    BASE_MSG="base-alterada"
    echo "DETALHE: arquivos da base mudados nesta cópia:"
    git status --porcelain --untracked-files=no | sed 's/^/  /'
    return
  fi
  if ! url="$(git remote get-url "$remoto" 2>/dev/null)"; then
    BASE_MSG="origem-mudou"
    echo "DETALHE: o remoto '$remoto' não existe nesta cópia."
    return
  fi
  garantir_versao
  registrada="$(campo "$VERSAO" Origem)"
  if [ -n "$registrada" ] && [ "$registrada" != "$url" ] && [ "$nova_origem" != 1 ]; then
    BASE_MSG="origem-mudou"
    echo "DETALHE: a origem registrada é $registrada, mas '$remoto' aponta para $url."
    return
  fi
  if ! saida="$(GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=2' \
      git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=15 \
      ls-remote --tags --refs "$remoto" 'v*' 2>&1)"; then
    BASE_MSG="sem-rede"
    echo "DETALHE: não consegui ler as versões de '$remoto':"
    printf '%s\n' "$saida" | sed 's/^/  /' | head -5
    return
  fi
  if [ -z "$registrada" ] || [ "$nova_origem" = 1 ]; then
    definir_campo "$VERSAO" Origem "$url"
    echo "ORIGEM REGISTRADA: $url"
  fi
  definir_campo "$VERSAO" "Última checagem" "$(hoje)"
  while read -r tag sha; do
    registrada="$(campo "$VERSAO" "Tag $tag")"
    if [ -n "$registrada" ] && [ "$registrada" != "$sha" ]; then
      BASE_MSG="tag-movida"
      echo "DETALHE: a tag $tag mudou de commit na origem desde que foi aplicada aqui."
      return
    fi
  done < <(printf '%s\n' "$saida" | awk '{ t = $2; sub("^refs/tags/", "", t); print t, $1 }')
  padrao='^v[0-9]+\.[0-9]+\.[0-9]+$'
  [ "$canal" = "candidata" ] && padrao='^v[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$'
  atual="$(chave_versao "$(versao_base)")"
  pular="$(campo "$VERSAO" "Pular até")"
  if [ "$auto" = 1 ] && [ -n "$pular" ] && [ "$(chave_versao "$pular")" \> "$atual" ]; then
    atual="$(chave_versao "$pular")"
  fi
  assinada="$(preferencia 'Exigir tag assinada' não)"
  base_ref="$(git rev-parse HEAD)"
  while read -r tag sha; do
    [ -n "$tag" ] || continue
    if ! GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=2' \
         git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=15 \
         fetch -q --no-tags "$remoto" "refs/tags/$tag:refs/tags/$tag" 2>/dev/null ||
       [ "$(git rev-parse "refs/tags/$tag")" != "$sha" ]; then
      BASE_MSG="tag-movida"
      echo "DETALHE: a tag $tag desta cópia não é a mesma da origem."
      return
    fi
    if [ "$assinada" = sim ] && ! git verify-tag "refs/tags/$tag" >/dev/null 2>&1; then
      BASE_MSG="tag-sem-assinatura"
      echo "DETALHE: a tag $tag não tem assinatura válida, e o config exige."
      return
    fi
    sha="$(git rev-parse "refs/tags/$tag^{commit}")"
    if [ "$(git show "$sha:VERSION" 2>/dev/null | tr -d '[:space:]')" != "${tag#v}" ]; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: a tag $tag não traz VERSION ${tag#v}; a versão não é coerente."
      return
    fi
    if ! git merge-base --is-ancestor "$base_ref" "$sha"; then
      BASE_MSG="historico-divergente"
      echo "DETALHE: $tag não descende da versão instalada; esta cópia pode ter commits próprios."
      return
    fi
    if [ -n "$(git ls-tree -r --name-only "$sha" | caminhos_da_pessoa | head -1)" ]; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: $tag passa a guardar no git arquivos que são da pessoa:"
      git ls-tree -r --name-only "$sha" | caminhos_da_pessoa | head -10 | sed 's/^/  /'
      return
    fi
    if colisoes="$(colisoes_com "$sha")"; [ -n "$colisoes" ]; then
      BASE_MSG="colisao"
      echo "DETALHE: $tag traz arquivos que já existem nesta pasta fora do git; nada foi mexido:"
      printf '%s\n' "$colisoes" | head -20 | sed 's/^/  /'
      return
    fi
    invalidos="$(nomes_invalidos "$base_ref" "$sha")"
    if [ -n "$invalidos" ]; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: $tag traz arquivos com nome fora do padrão:"
      printf '%s\n' "$invalidos" | head -10 | sed 's/^/  /'
      return
    fi
    invalidos="$(com_controles "$base_ref" "$sha")"
    if [ -n "$invalidos" ]; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: $tag traz caracteres de controle ou linhas enormes, que poderiam esconder texto no diff:"
      printf '%s\n' "$invalidos" | head -10 | sed 's/^/  /'
      return
    fi
    invalidos="$(git ls-tree -r --name-only "$sha" | atributos_do_git)"
    if [ -n "$invalidos" ]; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: $tag traz .gitattributes ou .lfsconfig, que fariam o diff mostrar uma coisa e o disco guardar outra:"
      printf '%s\n' "$invalidos" | head -10 | sed 's/^/  /'
      return
    fi
    sensiveis="$(mudancas_sensiveis "$base_ref" "$sha")"
    if printf '%s\n' "$sensiveis" | grep -q 'migração inválida'; then
      BASE_MSG="versao-invalida"
      echo "DETALHE: $tag traz uma migração que este script não aceita:"
      printf '%s\n' "$sensiveis" | grep 'migração inválida' | sed 's/^/  /'
      return
    fi
    if [ -n "$sensiveis" ]; then
      if [ "$tag" = "$aceito" ] && [ -f "$LOCAL/atualizacao-pendente.md" ] &&
         [ "$(campo "$LOCAL/atualizacao-pendente.md" Tag)" = "$tag" ] &&
         [ "$(campo "$LOCAL/atualizacao-pendente.md" Commit)" = "$sha" ] &&
         [ "$(campo "$LOCAL/atualizacao-pendente.md" 'Hash do diff')" = \
           "$(git diff --text --no-color --no-ext-diff --no-textconv "$base_ref" "$sha" | git hash-object --stdin)" ]; then
        echo "ACEITE: $tag no commit $sha, conferido pelo dono."
      else
        if [ "$tag" = "$aceito" ]; then
          echo "DETALHE: o aceite não vale: o que foi mostrado ao dono não é o commit $sha de $tag."
        fi
        PENDENTE="$tag"
        registrar_pendencia "$tag" "$sha" "$base_ref" "$sensiveis"
        return
      fi
    fi
    ALVO="$tag"; ALVO_SHA="$sha"; base_ref="$sha"
  done < <(printf '%s\n' "$saida" | awk '{ t = $2; sub("^refs/tags/", "", t); print t, $1 }' |
           while read -r t s; do
             if printf '%s\n' "$t" | grep -qE "$padrao" && [ "$(chave_versao "$t")" \> "$atual" ]; then
               echo "$(chave_versao "$t") $t $s"
             fi
           done | sort | cut -d' ' -f2-)
}

migrar() { # interpreta as migrações declarativas que faltam
  local f m n
  f="$(formato_local)"
  # shellcheck disable=SC2010 # só passam nomes do regex NOME_MIGRACAO, sem espaço nem símbolo
  for m in $(ls migracoes | grep -E "$NOME_MIGRACAO" | sort); do
    n=$((10#$(echo "$m" | cut -c1-3)))
    [ "$n" -gt "$f" ] || continue
    echo "MIGRAÇÃO: $m"
    if ! migracao aplicar "$(echo "$m" | cut -c1-3)" "migracoes/$m"; then
      echo "RESULTADO: erro na migração $m. Nada foi apagado; o backup está em ${BACKUP:-local/backups}."
      exit 1
    fi
    parar_se "depois-da-migracao-$(echo "$m" | cut -c1-3)"
    garantir_versao
    definir_campo "$VERSAO" "Formato local" "$n"
  done
}

cmd_novidades() { # de, para
  local de para
  de="$(chave_versao "$1")"; para="$(chave_versao "$2")"
  [ -f CHANGELOG.md ] || return 0
  while IFS= read -r linha; do
    if printf '%s\n' "$linha" | grep -qE '^## \['; then
      v="$(printf '%s\n' "$linha" | sed -E 's/^## \[([^]]+)\].*/\1/')"
      k="$(chave_versao "$v")"
      if [ "$k" \> "$de" ] && { [ "$k" \< "$para" ] || [ "$k" = "$para" ]; }; then mostrar=1; else mostrar=0; fi
    elif printf '%s\n' "$linha" | grep -qE '^# '; then
      mostrar=0
    fi
    [ "${mostrar:-0}" = 1 ] && printf '%s\n' "$linha"
  done < CHANGELOG.md
  return 0
}

cmd_estado() {
  echo "BASE NO DISCO: $(versao_base)"
  echo "BASE REGISTRADA: $(versao_registrada)"
  echo "FORMATO LOCAL: $(formato_local) de $(ultima_migracao)"
  echo "ATUALIZAÇÃO AUTOMÁTICA: $(preferencia 'Atualização automática' sim)"
  echo "CANAL: $(preferencia Canal estável)"
  echo "ÚLTIMA CHECAGEM: $(campo "$VERSAO" 'Última checagem')"
  echo "RESULTADO: $(situacao)"
}

cmd_iniciar() {
  local url t
  if [ -f config.local.md ]; then
    echo "RESULTADO: antigo (há config.local.md na raiz; rode scripts/maestro.sh atualizar)"
    return
  fi
  mkdir -p "$LOCAL/pautas" "$LOCAL/diario" "$LOCAL/arquivo" "$LOCAL/backups"
  if [ ! -f "$VERSAO" ]; then
    garantir_versao
    definir_campo "$VERSAO" Base "$(versao_base)"
    definir_campo "$VERSAO" "Formato local" "$(ultima_migracao)"
    definir_campo "$VERSAO" "Atualizado em" "$(agora)"
    definir_campo "$VERSAO" "Commit aplicado" "$(git rev-parse HEAD)"
    if url="$(git remote get-url origin 2>/dev/null)"; then definir_campo "$VERSAO" Origem "$url"; fi
    for t in $(git tag --points-at HEAD 'v*'); do
      definir_campo "$VERSAO" "Tag $t" "$(git rev-parse "refs/tags/$t")"
    done
  fi
  [ -f "$LOCAL/estado.md" ] || esqueleto_estado "$LOCAL/estado.md" "$(versao_base)"
  echo "RESULTADO: iniciado $(versao_base)"
}

cmd_atualizar() {
  local auto=0 aceito="" nova_origem=0 situ auto_on canal remoto de_base de_reg de_commit formato_antes resultado=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --auto) auto=1 ;;
      --aceitar) aceito="${2:-}"; shift ;;
      --aceitar-origem) nova_origem=1 ;;
      *) echo "RESULTADO: erro (opção desconhecida: $1)"; exit 1 ;;
    esac
    shift
  done

  situ="$(situacao)"
  if [ "$situ" = novo ]; then
    echo "RESULTADO: novo-usuario"
    return
  fi
  if [ "$situ" = sem-config ]; then
    echo "DETALHE: há registro do maestro em local/, mas não há local/config.md. Backups:"
    ls -1 "$LOCAL/backups" 2>/dev/null | tail -5 | sed 's/^/  /'
    echo "RESULTADO: sem-config"
    return
  fi
  travar
  if [ "$situ" = voltar-pendente ]; then
    voltar_continuar
    return
  fi

  auto_on="$(preferencia 'Atualização automática' sim)"
  canal="$(preferencia Canal estável)"
  remoto="$(campo "$(config_ativo)" 'Origem das atualizações' | tr -d '`' | sed 's/[ .]*$//')"
  remoto="${remoto:-origin}"
  de_base="$(versao_base)"
  de_reg="$(versao_registrada)"
  de_commit="$(campo "$VERSAO" 'Commit aplicado')"
  de_commit="${de_commit:-$(git rev-parse HEAD)}"
  formato_antes="$(formato_local)"
  ALVO=""; PENDENTE=""; BASE_MSG=""; BACKUP=""

  if [ "$auto" = 1 ] && [ "$auto_on" = "não" ]; then
    BASE_MSG="desligada"
  elif [ "$auto" = 1 ] && [ "$canal" != "estável" ] && [ "$canal" != "estavel" ]; then
    BASE_MSG="canal-$canal"
  elif [ "$auto" = 1 ] && [ "$situ" = em-dia ] && [ "$RETOMANDO" = 0 ] &&
       [ "$de_base" = "$de_reg" ] && [ "$de_commit" = "$(git rev-parse HEAD)" ] &&
       [ "$(campo "$VERSAO" 'Última checagem')" = "$(hoje)" ]; then
    # O limite de uma consulta por dia vale só para a origem; uma atualização
    # local que ficou pela metade é sempre concluída.
    echo "RESULTADO: ja-checado-hoje"
    return
  elif [ "$canal" = main ]; then
    BASE_MSG="canal-main"
  else
    escolher_alvo "$canal" "$remoto" "$aceito" "$auto" "$nova_origem"
  fi

  if [ -n "$ALVO" ] || [ "$formato_antes" -lt "$(ultima_migracao)" ] || [ "$situ" = antigo ]; then
    BACKUP="$(fazer_backup "$de_reg" "$(echo "${ALVO:-$de_base}" | sed 's/^v//')")"
    echo "BACKUP: $BACKUP"
  fi
  parar_se depois-do-backup

  if [ -n "$ALVO" ]; then
    if ! git merge -q --ff-only "$ALVO_SHA" 2>"$LOCAL/.erro-merge"; then
      echo "DETALHE: o git não avançou a base:"
      sed 's/^/  /' "$LOCAL/.erro-merge"
      rm -f "$LOCAL/.erro-merge"
      ALVO=""; BASE_MSG="base-alterada"
    else
      rm -f "$LOCAL/.erro-merge"
      if [ -n "$(git ls-files | caminhos_da_pessoa | head -1)" ] || ! git check-ignore -q "$CONFIG"; then
        git reset -q --keep "$(campo "$BACKUP/manifesto.md" Commit)"
        echo "RESULTADO: erro ($ALVO deixaria local/ visível ao git; a base voltou para $de_base)"
        exit 1
      fi
      [ -n "$PENDENTE" ] || rm -f "$LOCAL/atualizacao-pendente.md" "$LOCAL/atualizacao-pendente.diff"
      [ "$auto" = 1 ] || definir_campo "$VERSAO" "Pular até" ""
      definir_campo "$VERSAO" "Tag $ALVO" "$(git rev-parse "refs/tags/$ALVO")"
    fi
  fi
  parar_se depois-do-merge

  migrar

  garantir_versao
  local para
  para="$(versao_base)"
  if [ "$para" != "$de_reg" ] || [ "$(formato_local)" != "$formato_antes" ]; then
    definir_campo "$VERSAO" Base "$para"
    definir_campo "$VERSAO" "Atualizado em" "$(agora)"
    definir_campo "$VERSAO" "Versão anterior" "$de_reg"
    definir_campo "$VERSAO" "Commit aplicado" "$(git rev-parse HEAD)"
    [ -n "$BACKUP" ] && definir_campo "$VERSAO" Backup "$BACKUP"
  fi

  if [ "$para" != "$de_reg" ]; then echo "BASE: $de_reg -> $para"; else echo "BASE: $para"; fi
  if [ "$(formato_local)" != "$formato_antes" ]; then
    echo "FORMATO LOCAL: $formato_antes -> $(formato_local)"
  else
    echo "FORMATO LOCAL: $formato_antes"
  fi
  if [ "$de_commit" != "$(git rev-parse HEAD)" ]; then
    echo "ARQUIVOS QUE MUDARAM NESTA CÓPIA:"
    git diff --name-status --no-renames --no-ext-diff --no-textconv "$de_commit" HEAD | sed 's/^/  /'
  fi
  if [ "$para" != "$de_reg" ]; then
    echo "NOVIDADES (do CHANGELOG):"
    cmd_novidades "$de_reg" "$para"
  fi
  [ -n "$PENDENTE" ] && echo "PENDENTE: $PENDENTE precisa do ok do dono; a lista e o diff estão em $LOCAL/atualizacao-pendente.md"

  [ "$para" != "$de_reg" ] && resultado="atualizado $de_reg -> $para"
  if [ "$(formato_local)" != "$formato_antes" ]; then
    resultado="${resultado:+$resultado; }migrado $formato_antes -> $(formato_local)"
  fi
  [ -n "$PENDENTE" ] && resultado="${resultado:+$resultado; }precisa-aceite $PENDENTE"
  [ -n "$BASE_MSG" ] && resultado="${resultado:+$resultado; }$BASE_MSG"
  echo "RESULTADO: ${resultado:-em-dia $para}"
}

# Volta a base e local/ para um backup. É uma transação em três fases, anotadas
# em local/.voltando: guardar o que está aqui, restaurar o backup e voltar o git.
# Se for interrompida, a próxima execução de "voltar" ou "atualizar" termina.
cmd_voltar() {
  local dir="${1:-}" guardado
  if [ -f "$VOLTANDO" ]; then
    travar
    if [ -n "$dir" ] && [ "$dir" != "$(campo "$VOLTANDO" Backup)" ]; then
      echo "RESULTADO: erro (há outra volta pela metade, para $(campo "$VOLTANDO" Backup); termine-a antes)"
      exit 1
    fi
    voltar_continuar
    return
  fi
  if [ -z "$dir" ] || [ ! -f "$dir/manifesto.md" ]; then
    echo "RESULTADO: erro (informe a pasta de um backup em local/backups/)"
    exit 1
  fi
  if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    echo "RESULTADO: base-alterada (há arquivos da base mudados; não dá para voltar com segurança)"
    return
  fi
  travar
  guardado="$(pasta_nova "$LOCAL/backups/$(carimbo)-antes-de-voltar")"
  {
    echo "# Volta em andamento"
    echo
    echo "- **Backup:** $dir"
    echo "- **Guardado:** $guardado"
    echo "- **Commit:** $(campo "$dir/manifesto.md" Commit)"
    echo "- **De:** $(versao_registrada)"
    echo "- **Fase:** guardar"
  } > "$VOLTANDO.tmp"
  mv "$VOLTANDO.tmp" "$VOLTANDO"
  voltar_continuar novo
}

voltar_continuar() { # "novo" quando a volta acabou de começar
  local dir guardado commit de fase e rel retomado=" (retomado)"
  [ "${1:-}" = novo ] && retomado=""
  dir="$(campo "$VOLTANDO" Backup)"
  guardado="$(campo "$VOLTANDO" Guardado)"
  commit="$(campo "$VOLTANDO" Commit)"
  de="$(campo "$VOLTANDO" De)"
  fase="$(campo "$VOLTANDO" Fase)"
  mkdir -p "$guardado/local"

  if [ "$fase" = guardar ]; then
    for e in "$LOCAL"/* "$LOCAL"/.[!.]*; do
      [ -e "$e" ] || continue
      case "$(basename "$e")" in backups|provas|.atualizando|.voltando|.voltando.tmp) continue ;; esac
      mv "$e" "$guardado/local/"
    done
    if [ -d "$dir/raiz" ]; then
      (cd "$dir/raiz" && find . -type f | sed 's#^\./##') | while IFS= read -r rel; do
        if [ -e "$rel" ] && ! git ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then
          mkdir -p "$guardado/raiz/$(dirname "$rel")"
          mv "$rel" "$guardado/raiz/$rel"
        fi
      done
    fi
    definir_campo "$VOLTANDO" Fase restaurar
    fase=restaurar
    parar_se voltar-guardado
  fi

  if [ "$fase" = restaurar ]; then
    for e in "$LOCAL"/.restaurando-*; do
      [ -e "$e" ] || continue
      mkdir -p "$guardado/restos"
      mv "$e" "$guardado/restos/"
    done
    for e in "$dir/local"/* "$dir/local"/.[!.]*; do
      [ -e "$e" ] || continue
      rel="$(basename "$e")"
      case "$rel" in provas) continue ;; esac
      [ -e "$LOCAL/$rel" ] && continue
      cp -Rp "$e" "$LOCAL/.restaurando-$rel"
      mv "$LOCAL/.restaurando-$rel" "$LOCAL/$rel"
    done
    if [ -d "$dir/raiz" ]; then
      (cd "$dir/raiz" && find . -type f | sed 's#^\./##') | while IFS= read -r rel; do
        [ -e "$rel" ] && continue
        mkdir -p "$(dirname "$rel")"
        cp -p "$dir/raiz/$rel" "$rel"
      done
    fi
    definir_campo "$VOLTANDO" Fase git
    fase=git
  fi

  if [ "$(git rev-parse HEAD)" != "$commit" ]; then
    git reset -q --keep "$commit"
  fi
  if [ -f "$VERSAO" ]; then
    definir_campo "$VERSAO" "Pular até" "$de"
  fi
  mv "$VOLTANDO" "$guardado/volta-concluida.md"
  echo "GUARDADO: o estado de antes de voltar está em $guardado"
  echo "RESULTADO: voltou $de -> $(versao_base)$retomado"
}

main() {
  local cmd="${1:-estado}"
  [ $# -gt 0 ] && shift
  case "$cmd" in
    estado) cmd_estado ;;
    iniciar) cmd_iniciar ;;
    atualizar) cmd_atualizar "$@" ;;
    voltar) cmd_voltar "$@" ;;
    novidades) cmd_novidades "$@" ;;
    *) echo "RESULTADO: erro (comando desconhecido: $cmd)"; exit 1 ;;
  esac
}

main "$@"; exit $?
