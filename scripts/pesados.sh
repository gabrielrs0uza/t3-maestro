#!/usr/bin/env bash
# Mostra o que está pesando agora nas worktrees dos chats: servidores escutando
# em porta, builds, instalações, testes, navegadores de teste e containers. Só
# lê; não para nem apaga nada. O maestro roda antes de dar a vaga pesada, no
# resumo diário e quando a máquina aperta (skills/paralelo.md).
#
#   scripts/pesados.sh [--raiz <pasta>]... [--vagas <n>]
#
# --raiz: onde moram as worktrees dos chats (padrão: ~/.t3/worktrees). A demo
# mora fora delas e não entra na conta. --vagas: o limite; sem ele, vale o campo
# "Vagas pesadas" de local/config.md, e 1 se faltar.
#
# Conta uma vaga por worktree com algo pesado, não por processo: um servidor de
# desenvolvimento costuma abrir vários. A última linha é
#   RESULTADO: livre|cheio|acima <em uso> <vagas>
set -euo pipefail
unset CDPATH

RAIZ="$(cd -- "$(dirname -- "$0")/.." >/dev/null && pwd -P)"
. "$RAIZ/scripts/lib-maestro.sh"

raizes=()
vagas=""
while [ $# -gt 0 ]; do
  case "$1" in
    --raiz) [ -n "${2:-}" ] || { echo "uso: --raiz <pasta>" >&2; exit 2; }; raizes+=("$2"); shift ;;
    --vagas) vagas="${2:-}"; shift ;;
    *) echo "opção desconhecida: $1" >&2; exit 2 ;;
  esac
  shift
done
[ "${#raizes[@]}" -gt 0 ] || raizes=("$HOME/.t3/worktrees")
if [ -z "$vagas" ]; then
  vagas="$(campo "$RAIZ/local/config.md" "Vagas pesadas" | grep -oE '^[0-9]+' || true)"
fi
case "$vagas" in ''|*[!0-9]*) vagas=1 ;; esac

# Raízes com o caminho real, para comparar com a pasta de cada processo.
reais=()
for r in "${raizes[@]}"; do
  [ -d "$r" ] && reais+=("$(cd -- "$r" && pwd -P)")
done

# O que conta como pesado pelo comando. Quem escuta em porta conta sempre.
PADRAO='(^|[ /])(next|vite|webpack|turbo|tsc|jest|vitest|playwright|storybook|nuxt|astro|remix|expo|metro|gradle|xcodebuild|docker|cargo|esbuild|rollup)( |$)|(pnpm|npm|yarn|bun) (install|i|ci|add|dev|build|start|test|run)( |$)|(chrome|chromium).*(--headless|--remote-debugging)'

pasta_de() { # pid -> diretório atual do processo
  if [ -r "/proc/$1/cwd" ]; then
    readlink "/proc/$1/cwd" 2>/dev/null || true
  elif command -v lsof >/dev/null 2>&1; then
    lsof -a -p "$1" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1 || true
  fi
  return 0
}

worktree_de() { # pasta -> a worktree (dois níveis abaixo da raiz) ou vazio
  local p="$1" r resto
  for r in "${reais[@]+"${reais[@]}"}"; do
    case "$p" in
      "$r"/*)
        resto="${p#"$r"/}"
        printf '%s/%s\n' "$r" "$(printf '%s' "$resto" | cut -d/ -f1-2)"
        return 0 ;;
    esac
  done
  return 0
}

# Portas em escuta, uma linha "pid porta" por par.
portas=""
if command -v lsof >/dev/null 2>&1; then
  portas="$(lsof -nP -iTCP -sTCP:LISTEN -Fpn 2>/dev/null |
    awk '/^p/ { pid = substr($0, 2) } /^n/ { n = split($0, a, ":"); print pid, a[n] }' | sort -u || true)"
else
  echo "Aviso: sem lsof, as portas não aparecem." >&2
fi
portas_de() { # pid -> portas separadas por vírgula
  printf '%s\n' "$portas" | awk -v p="$1" '$1 == p { printf "%s%s", s, $2; s = "," }'
}

candidatos="$(
  { printf '%s\n' "$portas" | awk 'NF { print $1 }'
    ps -eo pid=,args= 2>/dev/null | grep -iE -- "$PADRAO" | awk '{print $1}' || true
  } | sort -un
)"

usadas=""
linhas=""
for pid in $candidatos; do
  [ "$pid" = "$$" ] && continue
  pasta="$(pasta_de "$pid")"
  [ -n "$pasta" ] || continue
  wt="$(worktree_de "$pasta")"
  [ -n "$wt" ] || continue
  inicio="$(ps -o lstart= -p "$pid" 2>/dev/null | sed 's/^ *//; s/ *$//' || true)"
  [ -n "$inicio" ] || continue
  usadas+="$wt"$'\n'
  kb="$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
  cmd="$(ps -o args= -p "$pid" 2>/dev/null | cut -c1-120 | sed 's/ *$//' || true)"
  porta="$(portas_de "$pid")"
  linhas+="$wt	PID $pid, desde $inicio, $(( ${kb:-0} / 1024 )) MB${porta:+, porta $porta}: $cmd"$'\n'
done

# Containers do docker compose cuja pasta de trabalho é uma worktree.
if command -v docker >/dev/null 2>&1; then
  while IFS='	' read -r id pasta nome; do
    [ -n "$id" ] || continue
    wt="$(worktree_de "$pasta")"
    [ -n "$wt" ] || continue
    usadas+="$wt"$'\n'
    linhas+="$wt	container $id ($nome)"$'\n'
  done < <(docker ps --format '{{.ID}}	{{.Label "com.docker.compose.project.working_dir"}}	{{.Names}}' 2>/dev/null || true)
fi

em_uso="$(printf '%s' "$usadas" | awk 'NF' | sort -u | wc -l | tr -d ' ')"
echo "Pesados agora ($(date -u '+%Y-%m-%d %H:%M UTC')), em ${raizes[*]}:"
if [ "$em_uso" -eq 0 ]; then
  echo "- nada pesado rodando nas worktrees"
else
  printf '%s' "$linhas" | sort | awk -F'\t' '$1 != ant { print "- " $1 ":"; ant = $1 } { print "    " $2 }'
fi
if command -v memory_pressure >/dev/null 2>&1; then
  memory_pressure -Q 2>/dev/null | sed -n 's/.*percentage: */Memória livre: /p' || true
elif [ -r /proc/meminfo ]; then
  awk '/^MemTotal/ {t=$2} /^MemAvailable/ {a=$2} END { if (t) printf "Memória livre: %d%%\n", a * 100 / t }' /proc/meminfo
fi
if [ "$em_uso" -lt "$vagas" ]; then situacao=livre
elif [ "$em_uso" -eq "$vagas" ]; then situacao=cheio
else situacao=acima
fi
echo "Vagas pesadas: $vagas · em uso: $em_uso"
echo "RESULTADO: $situacao $em_uso $vagas"
