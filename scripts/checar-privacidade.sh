#!/usr/bin/env bash
# Falha se um arquivo versionado tiver caminho de máquina, ID de chat, e-mail,
# credencial ou um termo da lista de termos proibidos, ou se algo de local/
# estiver no git. A lista fica em .github/termos-proibidos.sha256, como hashes,
# para não expor o que protege. Grafias com e sem acento, em maiúsculas ou com
# acento combinante contam como o mesmo termo, que também é procurado dentro de
# palavras e de nomes ligados por hífen ou sublinhado.
#
#   scripts/checar-privacidade.sh                     confere o repositório
#   scripts/checar-privacidade.sh --arquivo <caminho> confere um arquivo avulso,
#       como uma sugestão antes de sair da máquina, somando os termos privados
#       desta cópia: o nome do dono em local/config.md e cada linha de
#       local/termos-privados.txt
#   scripts/checar-privacidade.sh --hash <palavra>    imprime o hash para a lista
set -euo pipefail
unset CDPATH

cd -- "$(git rev-parse --show-toplevel)"

LISTA=.github/termos-proibidos.sha256

padroes='/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+/|mcp:launch:[0-9a-f]{16,}'
padroes+='|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}'
padroes+='|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}'

# A forma comparada de um termo ou trecho: Unicode decomposto, sem acentos, em
# minúsculas e só com letras e números ("Íris", "ÍRIS" e "iris" ficam
# iguais; "segredo-revisor" vira "segredorevisor"). A lista guarda o tamanho e
# o SHA-256 dessa forma.
PERL_NORMAL='
  use Unicode::Normalize qw(NFD);
  use Digest::SHA qw(sha256_hex);
  sub normal { my $t = NFD(shift); $t =~ s/\p{M}//g; return lc $t }
  sub esqueleto { my $t = normal(shift); $t =~ s/[^\p{L}\p{N}]//g; return $t }
  sub hash_de { my $x = shift; utf8::encode($x); return sha256_hex($x) }
'

hash_palavra() {
  printf '%s' "$1" | perl -CSA -e "$PERL_NORMAL"'
    local $/; my $e = esqueleto(<STDIN>);
    die "termo vazio\n" unless length $e;
    print length($e), " ", hash_de($e), "\n";'
}

# Imprime arquivo:linha de cada trecho cuja forma comparada está na lista. Confere
# substrings de cada palavra e de cada sequência ligada por hífen, sublinhado,
# ponto ou apóstrofo, e frases de até quatro palavras. O primeiro argumento é a
# lista; os outros, os arquivos.
procurar_termos() {
  perl -CSDA -e "$PERL_NORMAL"'
    my (%proibido, %tamanho);
    open(my $l, "<", shift @ARGV) or die;
    while (<$l>) {
      s/#.*//;
      next unless /^\s*(\d+)\s+([0-9a-f]{64})\s*$/;
      $proibido{$2} = 1; $tamanho{$1} = 1;
    }
    my @tamanhos = sort { $a <=> $b } keys %tamanho;
    sub tem_termo {
      my $s = shift; my $n_s = length $s;
      for my $n (@tamanhos) {
        last if $n > $n_s;
        for (my $i = 0; $i + $n <= $n_s; $i++) {
          return 1 if $proibido{hash_de(substr($s, $i, $n))};
        }
      }
      return 0;
    }
    my $achou = 0;
    for my $arq (@ARGV) {
      open(my $f, "<:encoding(UTF-8)", $arq) or next;
      LINHA: while (my $linha = <$f>) {
        my $t = normal($linha);
        for my $c ($t =~ /[\p{L}\p{N}]+(?:[-_.\x{27}][\p{L}\p{N}]+)*/g) {
          (my $e = $c) =~ s/[^\p{L}\p{N}]//g;
          if (tem_termo($e)) { print "$arq:$.: termo proibido\n"; $achou = 1; next LINHA }
        }
        my @p = $t =~ /[\p{L}\p{N}]+/g;
        for my $i (0 .. $#p) {
          my $frase = $p[$i];
          for my $k (1 .. 3) {
            last if $i + $k > $#p;
            $frase .= $p[$i + $k];
            if ($tamanho{length $frase} && $proibido{hash_de($frase)}) {
              print "$arq:$.: termo proibido\n"; $achou = 1; next LINHA;
            }
          }
        }
      }
    }
    exit $achou' "$@"
}

if [ "${1:-}" = "--hash" ]; then
  hash_palavra "${2:?informe a palavra}"
  exit 0
fi

falhou=0

if [ "${1:-}" = "--arquivo" ]; then
  arquivo="${2:?informe o arquivo}"
  lista="$(mktemp)"
  trap 'rm -f "$lista"' EXIT
  cat "$LISTA" > "$lista"
  if [ -f local/config.md ]; then
    dono="$(awk 'index($0, "- **Dono:**") == 1 { sub(/^- \*\*Dono:\*\*[ ]*/, ""); print; exit }' local/config.md)"
    for palavra in $dono; do
      [ "${#palavra}" -ge 3 ] && hash_palavra "$palavra" >> "$lista"
    done
  fi
  [ -n "${dono:-}" ] && hash_palavra "$dono" >> "$lista"
  if [ -f local/termos-privados.txt ]; then
    while IFS= read -r palavra || [ -n "$palavra" ]; do
      [ -n "$palavra" ] && hash_palavra "$palavra" >> "$lista"
    done < local/termos-privados.txt
  fi
  grep -n -E "$padroes" "$arquivo" && falhou=1
  procurar_termos "$lista" "$arquivo" || falhou=1
  if [ "$falhou" -ne 0 ]; then
    echo "Dados pessoais ou específicos encontrados nas linhas acima." >&2
    exit 1
  fi
  echo "Nenhum dado pessoal encontrado em $arquivo."
  exit 0
fi

ignorados=(
  ':!LICENSE'
  ':!skills/LICENSE'
  ":!$LISTA"
  ':!scripts/checar-privacidade.sh'
)

if git grep -n -I -E "$padroes" -- . "${ignorados[@]}"; then
  falhou=1
fi

textos=()
while IFS= read -r -d '' f; do textos+=("$f"); done < <(git grep -z -I -l -e '' -- . "${ignorados[@]}")
if [ "${#textos[@]}" -gt 0 ]; then
  procurar_termos "$LISTA" "${textos[@]}" || falhou=1
fi

if [ -n "$(git ls-files -- local config.local.md estado.md)" ]; then
  echo "Arquivos da pasta local/ ou da configuração da pessoa estão no git:" >&2
  git ls-files -- local config.local.md estado.md >&2
  falhou=1
fi

if [ "$falhou" -ne 0 ]; then
  echo "Dados pessoais ou específicos encontrados nos arquivos acima." >&2
  exit 1
fi

echo "Nenhum dado pessoal encontrado."
