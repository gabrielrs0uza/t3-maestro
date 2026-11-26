#!/usr/bin/env bash
# Suíte do scripts/pesados.sh: acha o servidor que roda dentro de uma worktree,
# ignora o que roda fora, conta uma vaga por worktree, conta container do docker,
# aguenta nome de pasta com quebra de linha, responde "desconhecido" quando não
# consegue olhar e não para nada. Os servidores de teste são encerrados no fim,
# também em falha ou Ctrl-C, e a suíte falha se sobrar algum.
set -euo pipefail
unset CDPATH
RAIZ="$(cd -- "$(dirname -- "$0")/.." >/dev/null && pwd -P)"
SCRIPT="$RAIZ/scripts/pesados.sh"
tmp="$(cd -- "$(mktemp -d)" && pwd -P)"
pids=()
encerrar() {
  local p
  for p in "${pids[@]+"${pids[@]}"}"; do kill "$p" 2>/dev/null || true; done
  for p in "${pids[@]+"${pids[@]}"}"; do wait "$p" 2>/dev/null || true; done
}
# shellcheck disable=SC2329 # chamada pelos traps abaixo
limpar() { encerrar; rm -rf "$tmp"; }
trap limpar EXIT
trap 'limpar; exit 130' INT
trap 'limpar; exit 143' TERM
falhou=0
ok() { echo "  ok: $1"; }
erro() { echo "  FALHOU: $1" >&2; falhou=1; }
ultimo() { printf '%s\n' "$1" | tail -1; }

# Sobe um servidor que escuta numa porta qualquer. Roda no shell atual, não num
# $(...), para o PID ficar em "pids"; o PID vai para a variável "servidor_pid".
# É um socket que só escuta: o http.server do Python consulta o DNS (getfqdn)
# entre ligar a porta e escutar, e no macOS do CI isso passou de 10 s. Sai
# sozinho em 10 minutos, se algo escapar da limpeza.
SERVIDOR='import socket, time; s = socket.socket(); s.bind(("127.0.0.1", 0)); s.listen(); time.sleep(600)'
MARCA=pesados-servidor-de-teste
servidor() { # pasta
  mkdir -p "$1"
  (cd -- "$1" && exec python3 -I -c "$SERVIDOR" "$MARCA" >>"$tmp/servidores.log" 2>&1) &
  servidor_pid=$!
  pids+=("$servidor_pid")
}
esperar_porta() { # pid
  for _ in $(seq 1 50); do
    lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN >/dev/null 2>&1 && return 0
    sleep 0.2
  done
  echo "  servidor $1: vivo=$(kill -0 "$1" 2>/dev/null && echo sim || echo não)" >&2
  sed 's/^/    log: /' "$tmp/servidores.log" >&2 || true
  lsof -nP -a -p "$1" 2>&1 | sed 's/^/    lsof: /' | tail -8 >&2 || true
  return 1
}

mkdir -p "$tmp/raiz" "$tmp/vazia" "$tmp/bin"
servidor "$tmp/raiz/projeto/t3-aaaa/app"; dentro=$servidor_pid
servidor "$tmp/raiz/projeto/t3-aaaa"; dentro2=$servidor_pid
servidor "$tmp/fora"; fora=$servidor_pid
for p in "${pids[@]}"; do esperar_porta "$p" || erro "servidor $p não abriu porta"; done

saida="$(bash "$SCRIPT" --raiz "$tmp/raiz" --vagas 1)"
case "$saida" in *"PID $dentro,"*"PID $dentro2,"*|*"PID $dentro2,"*"PID $dentro,"*) ok "acha os dois servidores dentro da worktree" ;; *) erro "não achou os servidores de dentro: $saida" ;; esac
case "$saida" in *"porta "*) ok "mostra a porta" ;; *) erro "não mostrou a porta" ;; esac
case "$saida" in *"PID $fora,"*) erro "contou o servidor de fora" ;; *) ok "ignora o que roda fora das worktrees" ;; esac
if [ "$(ultimo "$saida")" = "RESULTADO: cheio 1 1" ]; then ok "dois processos na mesma worktree são uma vaga"; else erro "resultado errado: $(ultimo "$saida")"; fi

saida="$(bash "$SCRIPT" --raiz "$tmp/raiz" --vagas 0)"
if [ "$(ultimo "$saida")" = "RESULTADO: acima 1 0" ]; then ok "acusa quando passa do limite"; else erro "não acusou o excesso"; fi

saida="$(bash "$SCRIPT" --raiz "$tmp/vazia" --vagas 1)"
if [ "$(ultimo "$saida")" = "RESULTADO: livre 0 1" ]; then ok "sem nada pesado, a vaga está livre"; else erro "vazio deu: $saida"; fi

# Docker simulado: um container do compose com pasta de trabalho numa worktree,
# outro sem rótulo e um terceiro fora das worktrees.
us=$'\037'
mkdir -p "$tmp/docker/bin" "$tmp/vazia/projeto/t3-cccc"
cat > "$tmp/docker/bin/docker" <<FIM
#!/bin/sh
printf 'abc123${us}$tmp/vazia/projeto/t3-cccc${us}app-db-1\n'
printf 'def456${us}${us}solto\n'
printf 'ghi789${us}$tmp/fora${us}outro\n'
FIM
chmod +x "$tmp/docker/bin/docker"
saida="$(PATH="$tmp/docker/bin:$PATH" bash "$SCRIPT" --raiz "$tmp/vazia" --vagas 1)"
if [ "$(ultimo "$saida")" = "RESULTADO: cheio 1 1" ]; then ok "conta o container do compose dentro da worktree"; else erro "docker simulado deu: $saida"; fi
case "$saida" in *"container abc123 (app-db-1)"*) ok "mostra o container" ;; *) erro "não mostrou o container: $saida" ;; esac
case "$saida" in *solto*|*def456*|*ghi789*) erro "contou container sem pasta ou de fora" ;; *) ok "ignora container sem pasta ou de fora" ;; esac

# Pasta com quebra de linha no nome: cada item continua numa linha só.
servidor "$tmp/raiz/projeto/t3-b"$'\n'"b"; quebra=$servidor_pid
esperar_porta "$quebra" || erro "servidor com quebra de linha não abriu porta"
saida="$(bash "$SCRIPT" --raiz "$tmp/raiz" --vagas 2)"
if [ "$(ultimo "$saida")" = "RESULTADO: cheio 2 2" ]; then ok "pasta com quebra de linha conta como uma worktree"; else erro "quebra de linha deu: $(ultimo "$saida")"; fi
soltas="$(printf '%s\n' "$saida" | grep -vE '^(Pesados agora|- |    |Memória livre|Vagas pesadas|RESULTADO)' || true)"
if [ -z "$soltas" ]; then ok "nenhuma linha quebrada na saída"; else erro "linhas quebradas: $soltas"; fi

# Raiz com quebra de linha no nome: o cabeçalho também fica numa linha só.
saida="$(bash "$SCRIPT" --raiz "$tmp/raiz"$'\n'"controle" --vagas 1)"
soltas="$(printf '%s\n' "$saida" | grep -vE '^(Pesados agora|- |    |Memória livre|Vagas pesadas|RESULTADO)' || true)"
if [ -z "$soltas" ] && printf '%s\n' "$saida" | head -1 | grep -qF "raiz?controle"; then
  ok "raiz com quebra de linha aparece numa linha só, com ?"
else
  erro "cabeçalho quebrado: $(printf '%s\n' "$saida" | head -3)"
fi

# Sem ps ou sem lsof, o script não consegue olhar: "desconhecido" e saída 3.
for c in bash dirname pwd awk sed grep sort cut tr wc date readlink head cat uname mkdir; do
  alvo="$(command -v "$c" || true)"
  [ -n "$alvo" ] && ln -s "$alvo" "$tmp/bin/$c"
done
for falta in ps lsof; do
  rm -rf "$tmp/bin-$falta"; cp -R "$tmp/bin" "$tmp/bin-$falta"
  for c in ps lsof; do
    [ "$c" = "$falta" ] && continue
    alvo="$(command -v "$c" || true)"; [ -n "$alvo" ] && ln -s "$alvo" "$tmp/bin-$falta/$c"
  done
  codigo=0
  saida="$(PATH="$tmp/bin-$falta" bash "$SCRIPT" --raiz "$tmp/raiz" --vagas 1 2>/dev/null)" || codigo=$?
  if [ "$(ultimo "$saida")" = "RESULTADO: desconhecido" ] && [ "$codigo" -ne 0 ]; then
    ok "sem $falta, responde desconhecido com saída $codigo"
  else
    erro "sem $falta deu \"$(ultimo "$saida")\" com saída $codigo"
  fi
done

for p in "${pids[@]}"; do
  kill -0 "$p" 2>/dev/null || erro "o processo $p morreu: o script só pode ler"
done
[ "$falhou" -eq 0 ] && ok "nenhum processo foi parado pelo script"

# No fim, nenhum servidor de teste pode sobrar.
encerrar
sobra=""
for p in "${pids[@]}"; do kill -0 "$p" 2>/dev/null && sobra="$sobra $p"; done
sobra2=""
while read -r p _; do
  pasta="$(lsof -a -p "$p" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' || true)"
  case "$pasta" in "$tmp"/*) sobra2="$sobra2 $p" ;; esac
done < <(pgrep -f -- "$MARCA" || true)
if [ -z "$sobra$sobra2" ]; then ok "nenhum servidor de teste sobrou"; else erro "sobraram servidores:$sobra$sobra2"; fi

if [ "$falhou" -eq 0 ]; then echo; echo "Todos os casos passaram."; fi
exit "$falhou"
