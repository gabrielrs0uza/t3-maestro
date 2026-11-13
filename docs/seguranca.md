# Segurança do atualizador

[English](security.md) · **Português**

O que `scripts/maestro.sh atualizar` e `voltar` fazem com a cópia de cada pessoa,
o que nunca fazem, o que o dono controla e o que fica sem proteção. Para relatar
uma vulnerabilidade, veja o [`SECURITY.md`](../SECURITY.md).

Em resumo: uma versão nova é conferida pelo script que já está instalado, sem
rodar nada que veio dela. Só documentação entra sozinha; o resto espera o dono ler
e confirmar. O que é da pessoa, em `local/`, nunca vai para o git nem é
sobrescrito.

## O que o atualizador nunca faz

- Rodar código baixado antes de o dono aceitar a versão. Migração é dado, lido
  pelo script instalado; shell baixado nunca roda.
- Aplicar regra, skill, script, migração, teste ou CI sem a confirmação do dono.
- Pôr `local/` no git, sobrescrever arquivo local ou apagar algo da pessoa.

## O que ele faz

Cada cópia é um clone do git, e a base avança de tag em tag (`vX.Y.Z`). A cada
versão nova:

1. **Confere antes de qualquer merge, com o script já instalado.** O código de
   uma versão só roda depois que ela foi aplicada.
2. **Aplica sozinho só documentação**, numa lista rasa e fechada, em arquivo
   comum (sem bit de execução, sem link simbólico):
   - `README.md` e `README.<idioma>.md` na raiz, `CHANGELOG.md`, `LICENSE`,
     `ORIGEM.md` e `VERSION`;
   - `docs/<nome>.md`, só na pasta `docs/`, sem subpastas;
   - imagens em `docs/assets/`.

   Nunca contam como documentação um caminho com componente que começa com `.`
   nem um nome de instrução de agente (`AGENTS*`, `CLAUDE*`, `GEMINI*`,
   `SKILL.md`, `.cursorrules` e parecidos), sem diferenciar maiúsculas.
3. **Pede uma confirmação do dono para todo o resto:** `AGENTS.md`, dentro ou
   fora do bloco fixo, `CLAUDE.md`, skills, `config.exemplo.md`, migrações,
   scripts, testes, CI, o próprio `SECURITY.md` e qualquer outro arquivo. O dono
   vê o resumo, a lista de arquivos e o diff completo, gerado com
   `git diff --text` e guardado em `local/atualizacao-pendente.diff`; a mudança
   no bloco fixo vem em destaque. O aceite vale para aquela tag, aquele commit e
   o hash daquele diff.
4. **Recusa, nem com aceite** (`versao-invalida`):
   - tag cujo `VERSION` não bate com o nome;
   - nome de arquivo fora de `[A-Za-z0-9._/-]`;
   - migração fora do vocabulário fechado, com link simbólico no caminho ou com
     origem que não é arquivo comum;
   - caminho que, em minúsculas, comece com `local/` ou seja `config.local.md`
     ou `estado.md`, antes ou depois do merge;
   - arquivo de texto com caractere de controle (NUL, CR solto, ESC, os de C1),
     caractere bidi ou de largura zero, BOM, ou linha com mais de 2000 bytes:
     tudo isso poderia esconder texto no diff;
   - `.gitattributes` ou `.lfsconfig`, em qualquer pasta e em qualquer caixa:
     filtros, `diff=`, `-diff` e LFS fariam o diff mostrar uma coisa e o disco
     guardar outra.

   O diff e o merge rodam com os atributos do sistema e do usuário
   neutralizados, sem textconv e sem diff externo.

   Versão que sobrescreveria um arquivo local fora do git dá `colisao` e não
   entra.
5. **Fixa a origem e as tags.** O endereço da origem é registrado na primeira
   atualização. Origem trocada dá `origem-mudou`; tag aplicada que muda de
   commit, `tag-movida`; histórico que não descende do instalado,
   `historico-divergente`. Tag assinada é opcional ("Exigir tag assinada" no
   `local/config.md`). O `ls-remote` e o `git fetch` da tag têm os mesmos limites:
   não pedem senha, têm tempo de conexão, limite de velocidade e derrubam uma
   conexão ssh parada.
6. **Faz backup de tudo o que é local** antes de mudar a base, em
   `local/backups/<data>-<de>-para-<para>/`: `local/` e os arquivos da raiz que o
   git não acompanha, inclusive os ignorados. Em `local/`, link simbólico é
   copiado como link; nos arquivos da raiz, o backup segue o link e guarda o
   conteúdo do alvo (veja "Limites conhecidos").
7. **Aguenta corte e repetição.** Atualizar e voltar anotam cada fase e retomam
   de onde pararam, e todo nome novo é exclusivo. Enquanto o processo dono da trava
   estiver vivo, conferido pelo PID e pela hora de início dele, o resultado é
   `ocupado`, sem limite de idade; a trava só é retomada quando esse processo
   morreu. O gancho de teste `MAESTRO_PARAR_EM` só
   é lido do ambiente do processo: uma versão nova não consegue defini-lo sem
   passar pela confirmação do dono.
8. **Volta atrás a pedido:** `scripts/maestro.sh voltar local/backups/<pasta>`
   devolve a base e `local/` ao que eram. O estado de antes da volta fica em
   outro backup, e a versão abandonada não volta sozinha.

## O que o dono controla

- **As aprovações fixas.** O bloco fixo do `AGENTS.md` exige a aprovação do dono
  para merge, deploy, alteração em dados de produção e exclusões. Configuração,
  `local/` e skills só podem acrescentar aprovações. Uma versão que mexa nesse
  bloco só entra com a confirmação dele, com o diff do bloco em destaque.
- **Cada versão que pede confirmação.** O maestro pergunta uma vez, "atualizo
  para vX?"; sem o sim, nada muda.
- **A atualização automática** ("Atualização automática: não" desliga), o canal,
  a exigência de tag assinada e a volta atrás.
- **No GitHub**, os ajustes que nenhum commit faz estão em
  [O que só o dono liga](pagina-github.md#o-que-só-o-dono-liga).

## Limites conhecidos

- **Confiança no primeiro uso.** A origem registrada é a do remoto na primeira
  atualização; se ela já estava errada, o script confia nela.
- **Depende da conta de quem publica as tags.** Quem controla essa conta publica
  uma versão. Só documentação entraria sozinha, mas o resto chega ao dono como
  pedido legítimo. Tag assinada reduz isso para quem a exigir.
- **Regras são texto para um agente com acesso amplo.** O script mostra tudo, mas
  não lê pelo dono: ele deve ler o que aceita. O script também não distingue o
  dono do agente ao receber `--aceitar`; a barreira é a regra escrita e a
  confirmação no chat.
- **Documentação que entra sozinha pode enganar uma pessoa**, mas não vira regra
  para o agente, que não segue `README`, `docs/` nem `CHANGELOG` como ordem.
- **Não protege contra quem já controla a máquina ou o git local:** o script
  instalado, o config do git, `local/versao.md` ou as credenciais.
- **`SECURITY.md` não está na lista de documentação**, então uma versão que mude
  esse arquivo pede confirmação.
- **Backups sem criptografia:** `local/backups/` tem a proteção da máquina.
- **Hash não é segredo:** quem tem um palpite confirma se um termo está na lista
  de termos proibidos, e a checagem de privacidade só pega o que estiver nela.
- **O gancho de teste `MAESTRO_PARAR_EM` continua no script.** Ele interrompe a
  atualização num ponto escolhido e só é lido do ambiente do processo. Uma versão
  nova não consegue defini-lo sem passar pela confirmação do dono.
- **O backup guarda mais do que `local/`.** Ele copia também os arquivos da raiz
  que o git ignora, como `.claude/`, e, nesses, segue link simbólico: guarda o
  conteúdo do alvo, não o link. Tudo fica em `local/backups/`, na própria
  máquina.

## Para a 2.1

O que fica para a próxima versão, sem data marcada:

- Manter `MAESTRO_PARAR_EM` só no ambiente do processo e documentado, como hoje.
- No backup, copiar link simbólico como link e rever a cópia dos arquivos
  ignorados da raiz.

## O que os testes provam

Duas suítes, em pastas temporárias e sem rede:

- `tests/atualizacao.sh`, cenários (a) a (z), com origens sintéticas. Rode
  `bash tests/atualizacao.sh --verboso`. Cada comando roda com `CDPATH=.:/tmp`.
- `tests/privacidade.sh`, a checagem de privacidade com termos fictícios:
  maiúsculas, sem acento, acento combinante (NFD), termo dentro de palavra, entre
  hífens ou sublinhados, frases, nome do dono e um texto limpo.

| O que o cenário prova | Cenários |
|---|---|
| Só documentação entra sozinha; regra fixa, regra fora do bloco, skill e script pedem o ok | (a), (i) `script`, (s) `regra` |
| Documentação em arquivo executável pede o ok | (i) `exec` |
| Nada da versão nova roda antes do aceite: migração em shell, biblioteca nova | (i) `shell`, `lib` |
| Migração fora do vocabulário é recusada, nem com aceite | (i) `base`, (s) |
| Migração diante de link simbólico, link pendente e arquivo especial | (r) |
| Versão que rastreia `local/provas/` é recusada, nem com aceite; colisão com arquivo ignorado | (k) |
| Nome com espaço, em migração e em script | (p), (q) |
| `VERSION` diferente da tag | (o) |
| O diff completo guardado até a última linha; com o aceite entra o que foi guardado | (q) |
| Origem trocada, tag movida depois de mostrada, tag sem assinatura exigida | (j) |
| Commits próprios na cópia; base alterada na cópia | (g), (e) |
| Backup com `local/`, provas e arquivos da raiz | (b), (k) |
| Corte no meio, retomada, duas operações no mesmo segundo, volta interrompida | (c), (l), (m), (n) |
| Voltar sem a versão abandonada voltar sozinha | (h), (m) |
| Atualização desligada, canal candidata, sem rede | (f), (d) |
| Instrução de agente disfarçada de documentação, em subpasta, com ponto ou com outra caixa; subpasta em `docs/` | (t) |
| Caminho da pessoa com outra caixa (`Local/`, `Estado.md`), nem com aceite | (u) |
| Texto com byte NUL, nem com aceite | (v) |
| CR solto, ESC, bidi, largura zero e linha enorme, nem com aceite | (w) |
| `.gitattributes` com `filter=`, `-diff` e `diff=`, em qualquer pasta e caixa, e `.lfsconfig`, nem com aceite; filtro nos atributos do usuário não muda o que é gravado | (x) |
| Trava antiga com o processo dono vivo dá `ocupado`; com ele morto, a atualização retoma | (y) |
| O `fetch` da tag com os limites de rede | (z) |

Sem cenário nesta suíte, valendo só pelo código: o hash do diff no aceite, link
simbólico e gitlink em documentação, o limite de rede do `ls-remote` e `MAESTRO_PARAR_EM` vindo
de uma versão nova.

## O que o CI confere

- `.github/workflows/ci.yml`, a cada push e PR: `Privacidade`
  (`scripts/checar-privacidade.sh` e `tests/privacidade.sh`), `Base coerente`
  (`scripts/checar-base.sh`), `Testes` (`tests/atualizacao.sh` em Ubuntu e
  macOS, com e sem `CDPATH` exportado), `Shellcheck` (falha a partir de
  `warning`) e `Gitleaks` (todo o histórico).
- `.github/workflows/scorecard.yml`: OpenSSF Scorecard só no ramo padrão, toda
  semana, a cada push na `main` e quando a proteção de branch muda. Publica a
  nota, que alimenta o selo, e manda o SARIF para Code scanning.
- `.github/dependabot.yml`: um PR por semana para atualizar as actions.
- `permissions: contents: read` no topo e em cada job; só o Scorecard tem
  `security-events: write` e `id-token: write`. Actions fixadas por SHA
  completo, com a versão em comentário, e checkout sem credencial guardada.
  Shellcheck e gitleaks vêm das releases oficiais, conferidos por SHA-256.
- O SHA fixa o `action.yaml` do Scorecard, mas não a imagem Docker que ele
  baixa, que vem da tag da própria action.
