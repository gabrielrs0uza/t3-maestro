# shellcheck shell=bash
# Funções usadas por scripts/maestro.sh e pelas migrações. Para usar:
#   . scripts/lib-maestro.sh
# Os campos são linhas de Markdown no formato "- **Nome:** valor".

# Imprime o valor do campo, ou nada se o arquivo ou o campo não existir.
campo() {
  [ -f "$1" ] || return 0
  awk -v nome="$2" '
    index($0, "- **" nome ":**") == 1 {
      sub(/^- \*\*[^*]*:\*\*[ ]*/, "")
      print
      exit
    }' "$1"
}

# Valor do campo sem crases, sem ponto final e em minúsculas.
campo_simples() {
  campo "$1" "$2" | tr -d '`' | sed 's/[. ]*$//' | tr '[:upper:]' '[:lower:]'
}

tem_campo() {
  [ -f "$1" ] && awk -v nome="$2" '
    index($0, "- **" nome ":**") == 1 { achou = 1 }
    END { exit !achou }' "$1"
}

# Troca o valor do campo; se ele não existir, acrescenta no fim do arquivo.
definir_campo() {
  local arq="$1" nome="$2" valor="$3" tmp
  tmp="$arq.tmp.$$"
  if tem_campo "$arq" "$nome"; then
    NOME="$nome" LINHA="- **$nome:** $valor" awk '
      index($0, "- **" ENVIRON["NOME"] ":**") == 1 && !feito { print ENVIRON["LINHA"]; feito = 1; next }
      { print }' "$arq" > "$tmp"
  else
    { if [ -f "$arq" ]; then cat "$arq"; fi
      printf -- '- **%s:** %s\n' "$nome" "$valor"; } > "$tmp"
  fi
  mv "$tmp" "$arq"
}

# Acrescenta o campo na seção "## <secao>" se ele ainda não existir em lugar
# nenhum do arquivo. Nunca muda um valor que a pessoa já escreveu. Se a seção não
# existir, ela é criada antes de "## Regras do time", ou no fim do arquivo.
garantir_campo() {
  local arq="$1" secao="## $2" nome="$3" valor="$4" modo tmp
  tem_campo "$arq" "$nome" && return 0
  if grep -qxF "$secao" "$arq"; then modo=inserir; else modo=nova; fi
  tmp="$arq.tmp.$$"
  MODO="$modo" SECAO="$secao" LINHA="- **$nome:** $valor" awk '
    BEGIN { modo = ENVIRON["MODO"]; secao = ENVIRON["SECAO"]; linha = ENVIRON["LINHA"] }
    function solta(   i) {
      if (!feito) { print linha; feito = 1 }
      for (i = 0; i < vazias; i++) print ""
      vazias = 0
    }
    modo == "nova" && !feito && $0 == "## Regras do time" {
      print secao; print ""; print linha; print ""; feito = 1; print; next
    }
    modo == "inserir" && $0 == secao { dentro = 1; print; next }
    dentro && /^## / { solta(); dentro = 0; print; next }
    dentro && /^[ \t]*$/ { vazias++; next }
    dentro {
      for (i = 0; i < vazias; i++) print ""
      vazias = 0
      print
      next
    }
    { print }
    END {
      if (dentro) solta()
      else if (!feito) { print ""; print secao; print ""; print linha }
    }' "$arq" > "$tmp"
  mv "$tmp" "$arq"
}

# Chave que ordena versões: 2.10.0 > 2.9.0 e 2.1.0 > 2.1.0-rc.3.
chave_versao() {
  awk -v v="$1" 'BEGIN {
    sub(/^v/, "", v)
    rc = 999
    if (match(v, /-rc\.[0-9]+$/)) { rc = substr(v, RSTART + 4) + 0; v = substr(v, 1, RSTART - 1) }
    split(v, a, ".")
    printf "%03d%03d%03d%03d\n", a[1], a[2], a[3], rc
  }'
}

# Diz se uma mudança neste caminho pode entrar sem o ok do dono: só
# documentação que o agente não segue como regra, numa lista rasa e fechada. Um
# componente que começa com "." e qualquer nome de arquivo de instrução de agente,
# sem diferenciar maiúsculas, nunca contam como documentação. AGENTS.md,
# CLAUDE.md, skills, config de exemplo, migrações, scripts, testes, CI e qualquer
# outro arquivo voltam 1 e pedem uma confirmação.
arquivo_de_documentacao() { # caminho
  local minusculo
  minusculo="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "/$minusculo" in */.*) return 1 ;; esac
  case "$(basename "$minusculo")" in
    agents*|claude*|gemini*|skill.md|copilot*|cursor*|*.mdc|codex*|.*) return 1 ;;
  esac
  printf '%s\n' "$1" | grep -qE '^(README(\.[A-Za-z-]+)?\.md|CHANGELOG\.md|LICENSE|ORIGEM\.md|VERSION|docs/[A-Za-z0-9_-][A-Za-z0-9._-]*\.md|docs/assets/[A-Za-z0-9_-][A-Za-z0-9._-]*\.(svg|png|jpg))$'
}

# Caminho dentro de local/, sem "..", sem barra dupla e só com caracteres simples.
caminho_local_ok() {
  printf '%s\n' "$1" | grep -qE '^local/[A-Za-z0-9._/-]+$' || return 1
  case "/$1/" in */../*|*/./*|*//*) return 1 ;; esac
  return 0
}

# Confere no disco um caminho dentro de local/: nenhum componente pode ser link
# simbólico, e os que já existem antes do último têm de ser pastas comuns. Assim
# o caminho real fica dentro de local/, sem seguir links. Com "pasta", o último
# também tem de ser pasta comum, se existir; com "destino", ele não pode ser link.
caminho_local_seguro() { # caminho, pasta|destino
  local p="" parte IFS=/
  for parte in $1; do
    p="${p:+$p/}$parte"
    [ -L "$p" ] && return 1
    if [ "$p" != "$1" ] || [ "$2" = pasta ]; then
      [ ! -e "$p" ] || [ -d "$p" ] || return 1
    fi
  done
  return 0
}

# A origem de mover/arquivar: arquivo comum, nunca link nem arquivo especial.
# Se não existir, a operação não faz nada.
origem_segura() {
  [ -L "$1" ] && return 1
  [ ! -e "$1" ] || [ -f "$1" ]
}

# Arquivo solto na raiz da pasta do mestre, que o git não acompanha.
caminho_raiz_ok() {
  printf '%s\n' "$1" | grep -qE '^[A-Za-z0-9_-][A-Za-z0-9._-]*$' || return 1
  ! git ls-files --error-unmatch -- "$1" >/dev/null 2>&1
}

# Interpreta uma migração declarativa (migracoes/NNN-nome.txt). Uma operação por
# linha, campos separados por " | ":
#   pasta | local/x               cria a pasta
#   mover | arquivo | local/x     move da raiz para local/; não sobrescreve
#   arquivar | arquivo | local/x  move da raiz para local/, com nome único
#   criar-estado                  cria local/estado.md se faltar
#   campo | Nome | valor          acrescenta ao config um campo da lista fechada
#   tarefa | CÓDIGO               avisa o mestre de uma tarefa da lista fechada
# Modo "validar" só confere; "aplicar" executa. O arquivo "-" é a entrada.
migracao() { # modo, número, arquivo
  local modo="$1" num="$2" arq="$3" linha nf op a b c d n=0
  if [ "$arq" != - ] && { [ ! -f "$arq" ] || [ -L "$arq" ] || [ ! -r "$arq" ]; }; then
    echo "MIGRAÇÃO INVÁLIDA: $num: não consegui ler $arq"
    return 1
  fi
  while IFS= read -r linha || [ -n "$linha" ]; do
    n=$((n + 1))
    case "$linha" in ''|'#'*) continue ;; esac
    IFS=$'\037' read -r nf op a b c d <<FIM
$(printf '%s\n' "$linha" | awk -F' [|] ' '{ printf "%d", NF; for (i = 1; i <= NF; i++) printf "%c%s", 31, $i; print "" }')
FIM
    if ! migracao_valida "$nf" "$op" "$a" "$b" "$c"; then
      echo "MIGRAÇÃO INVÁLIDA: $num, linha $n: $linha"
      return 1
    fi
    [ "$modo" = aplicar ] || continue
    migracao_aplica "$op" "$a" "$b" "$c" "$d" || { echo "MIGRAÇÃO FALHOU: $num, linha $n: $linha"; return 1; }
    parar_se "$num-$op"
  done < <(if [ "$arq" = - ]; then cat; else cat -- "$arq"; fi)
}

# Os campos que uma migração pode acrescentar, com a seção e os valores aceitos.
# "Regras do time" e qualquer outra seção do dono ficam de fora. Imprime a seção.
campo_permitido() { # nome, valor
  local secao valores
  case "$1" in
    "Abrir chats sem perguntar") secao=Operação; valores="sim|não|perguntar" ;;
    "Chats rodando ao mesmo tempo"|"Vagas pesadas"|"Rodadas de revisão por PR") secao=Operação; valores=numero ;;
    "Rodapé de pedidos") secao=Operação; valores="sim|não" ;;
    "Pasta de provas") secao=Operação; valores=caminho ;;
    "Demo") secao=Operação; valores="nenhuma" ;;
    "Faxina") secao=Operação; valores="semanal|não quero" ;;
    "Faxina automática") secao=Operação; valores="não" ;;
    "Atualização automática"|"Exigir tag assinada") secao=Atualização; valores="sim|não" ;;
    "Canal") secao=Atualização; valores="estável|candidata|main" ;;
    "Origem das atualizações") secao=Atualização; valores=remoto ;;
    *) return 1 ;;
  esac
  case "$valores" in
    numero) printf '%s' "$2" | grep -qE '^[0-9]{1,2}$' || return 1 ;;
    caminho) caminho_local_ok "$2" || return 1 ;;
    remoto) printf '%s' "$2" | LC_ALL=C grep -qE '^[A-Za-z0-9._-]{1,40}$' || return 1 ;;
    *) case "|$valores|" in *"|$2|"*) ;; *) return 1 ;; esac ;;
  esac
  echo "$secao"
}

# As tarefas que uma migração pode pedir ao mestre. Cada código tem a sua
# condição aqui, e o que o mestre faz com ele está em skills/atualizar.md.
tarefa_permitida() {
  case "$1" in
    MONTAR_PAUTAS|AVISAR_ATUALIZACAO|PERGUNTAR_PARALELO|CRIAR_ROTINA_ATUALIZACAO) return 0 ;;
    *) return 1 ;;
  esac
}

migracao_valida() { # nf, op, a, b, c
  case "$2" in
    pasta) [ "$1" = 2 ] && caminho_local_ok "$3" && caminho_local_seguro "$3" pasta ;;
    mover|arquivar)
      [ "$1" = 3 ] && caminho_raiz_ok "$3" && caminho_local_ok "$4" &&
        origem_segura "$3" && caminho_local_seguro "$4" destino ;;
    criar-estado) [ "$1" = 1 ] ;;
    campo) [ "$1" = 3 ] && campo_permitido "$3" "$4" >/dev/null ;;
    tarefa) [ "$1" = 2 ] && tarefa_permitida "$3" ;;
    *) return 1 ;;
  esac
}

migracao_aplica() { # op, a, b, c, d
  local secao
  case "$1" in
    pasta) mkdir -p "$2" ;;
    mover)
      [ -e "$2" ] || return 0
      if [ ! -e "$3" ]; then mkdir -p "$(dirname "$3")"; mv -n "$2" "$3"; [ ! -e "$2" ]
      elif cmp -s "$2" "$3"; then mover_sem_sobrescrever "$2" "local/arquivo/$2"
      else
        echo "ERRO: $2 e $3 existem com conteúdos diferentes. Junte os dois em $3, guarde o outro em local/arquivo/ e rode de novo." >&2
        return 1
      fi ;;
    arquivar)
      [ -e "$2" ] || return 0
      mover_sem_sobrescrever "$2" "$3" ;;
    criar-estado)
      [ -f local/estado.md ] && return 0
      esqueleto_estado local/estado.md "$(tr -d '[:space:]' < VERSION)"
      if ls local/arquivo/estado-v1*.md >/dev/null 2>&1; then
        printf '\nMigração da versão 1: pendente. Monte as pautas e este índice a partir de local/arquivo/estado-v1*.md e apague esta linha.\n' >> local/estado.md
      fi ;;
    campo)
      [ -f local/config.md ] || return 0
      secao="$(campo_permitido "$2" "$3")" || return 1
      garantir_campo local/config.md "$secao" "$2" "$3" ;;
    tarefa)
      case "$2" in
        MONTAR_PAUTAS) grep -qF 'Migração da versão 1: pendente' local/estado.md 2>/dev/null || return 0 ;;
        PERGUNTAR_PARALELO) [ "$(campo_simples local/config.md 'Abrir chats sem perguntar')" = perguntar ] || return 0 ;;
      esac
      echo "TAREFA: $2" ;;
  esac
}

# Move para o destino ou, se ele existir, para x-<data>.md, x-<data>-2.md e assim
# por diante. Nunca sobrescreve: "mv -n" não troca um arquivo existente, e a
# origem só some quando o destino foi criado.
mover_sem_sobrescrever() { # origem, destino
  local base ext alvo n=1
  mkdir -p "$(dirname "$2")"
  base="${2%.*}"; ext="${2##*.}"
  case "$ext" in */*|"$2") base="$2"; ext="" ;; *) ext=".$ext" ;; esac
  alvo="$2"
  while [ -e "$1" ]; do
    if [ ! -e "$alvo" ] && [ ! -L "$alvo" ]; then mv -n "$1" "$alvo" || true; fi
    [ -e "$1" ] || return 0
    if [ "$n" = 1 ]; then alvo="$base-$(date -u '+%Y%m%dT%H%M%SZ')$ext"
    else alvo="$base-$(date -u '+%Y%m%dT%H%M%SZ')-$n$ext"; fi
    n=$((n + 1))
    [ "$n" -lt 1000 ] || return 1
  done
}

# Cria uma pasta nova com o nome pedido ou, se ele existir, com -2, -3...
# Imprime o nome criado. "mkdir" sem -p falha se a pasta existir.
pasta_nova() { # caminho
  local alvo="$1" n=1
  mkdir -p "$(dirname "$1")"
  until mkdir "$alvo" 2>/dev/null; do
    n=$((n + 1))
    alvo="$1-$n"
    [ "$n" -lt 1000 ] || return 1
  done
  echo "$alvo"
}

# Ponto de parada para os testes simularem uma atualização interrompida.
parar_se() {
  if [ "${MAESTRO_PARAR_EM:-}" = "$1" ]; then
    kill -9 "${MAESTRO_PID:-$$}" "$$"
  fi
}

# Cria o índice vazio em local/estado.md, no modelo de skills/pedidos.md.
esqueleto_estado() { # arquivo, versão
  cat > "$1" <<FIM
# Estado

Atualizado: $(date -u '+%Y-%m-%d %H:%M UTC') · Regras: v$2 · Visto até: —

## Depende de você

## Pautas

| Projeto | Arquivo | Abertos | Esperando você |
|---|---|---|---|

## Chats vivos

| Título | Chat | threadId | Projeto | Executor | Estado | Pedidos | PR | Lido até | Último aviso |
|---|---|---|---|---|---|---|---|---|---|

## Vaga pesada

## Demo

## Rotinas
FIM
}
