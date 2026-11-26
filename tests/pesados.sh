#!/usr/bin/env bash
# Suíte do scripts/pesados.sh: acha o servidor que roda dentro de uma worktree,
# ignora o que roda fora, conta uma vaga por worktree e não para nada.
set -euo pipefail
unset CDPATH
RAIZ="$(cd -- "$(dirname -- "$0")/.." >/dev/null && pwd -P)"
tmp="$(mktemp -d)"
pids=()
limpar() { for p in "${pids[@]+"${pids[@]}"}"; do kill "$p" 2>/dev/null || true; done; rm -rf "$tmp"; }
trap limpar EXIT
falhou=0
ok() { echo "  ok: $1"; }
erro() { echo "  FALHOU: $1" >&2; falhou=1; }

servidor() { # pasta -> pid de um servidor que escuta numa porta qualquer
  mkdir -p "$1"
  (cd -- "$1" && exec python3 -I -m http.server 0 --bind 127.0.0.1 >/dev/null 2>&1) &
  pids+=("$!")
  echo "$!"
}
esperar_porta() { # pid
  for _ in $(seq 1 50); do
    lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN >/dev/null 2>&1 && return 0
    sleep 0.2
  done
  return 1
}

mkdir -p "$tmp/raiz" "$tmp/vazia"
dentro="$(servidor "$tmp/raiz/projeto/t3-aaaa/app")"
dentro2="$(servidor "$tmp/raiz/projeto/t3-aaaa")"
fora="$(servidor "$tmp/fora")"
for p in "$dentro" "$dentro2" "$fora"; do esperar_porta "$p" || erro "servidor $p não abriu porta"; done

saida="$(bash "$RAIZ/scripts/pesados.sh" --raiz "$tmp/raiz" --vagas 1)"
case "$saida" in *"PID $dentro,"*) ok "acha o servidor dentro da worktree" ;; *) erro "não achou o servidor de dentro: $saida" ;; esac
case "$saida" in *"porta "*) ok "mostra a porta" ;; *) erro "não mostrou a porta" ;; esac
case "$saida" in *"PID $fora,"*) erro "contou o servidor de fora" ;; *) ok "ignora o que roda fora das worktrees" ;; esac
[ "$(printf '%s\n' "$saida" | tail -1)" = "RESULTADO: cheio 1 1" ] && ok "dois processos na mesma worktree são uma vaga" || erro "resultado errado: $(printf '%s\n' "$saida" | tail -1)"

saida="$(bash "$RAIZ/scripts/pesados.sh" --raiz "$tmp/raiz" --vagas 0)"
[ "$(printf '%s\n' "$saida" | tail -1)" = "RESULTADO: acima 1 0" ] && ok "acusa quando passa do limite" || erro "não acusou o excesso"

saida="$(bash "$RAIZ/scripts/pesados.sh" --raiz "$tmp/vazia" --vagas 1)"
[ "$(printf '%s\n' "$saida" | tail -1)" = "RESULTADO: livre 0 1" ] && ok "sem nada pesado, a vaga está livre" || erro "vazio deu: $saida"

for p in "$dentro" "$dentro2" "$fora"; do
  kill -0 "$p" 2>/dev/null || erro "o processo $p morreu: o script só pode ler"
done
[ "$falhou" -eq 0 ] && ok "nenhum processo foi parado"

if [ "$falhou" -eq 0 ]; then echo; echo "Todos os casos passaram."; fi
exit "$falhou"
