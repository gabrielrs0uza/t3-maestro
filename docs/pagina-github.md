# Página do repositório no GitHub

Ajustes que só quem administra o repositório pode fazer, nas configurações do
GitHub. Nada aqui é aplicado por commit. A página é a primeira coisa que um
visitante vê, então os valores ficam em inglês; o `README.md` já abre em inglês e
leva ao `README.pt-BR.md`.

## Descrição curta (About)

Na página do repositório, clique na engrenagem ao lado de "About".

- **Description:** Rules for T3 Code: you talk to one chat, the conductor. It opens
  a chat for each problem, keeps an eye on all of them and tells you what changed.
- **Website:** deixe vazio.
- **Topics:** `t3-code`, `ai-agents`, `agents-md`, `claude`, `codex`,
  `multi-agent`, `orchestration`, `git-worktree`, `developer-tools`, `pt-br`.
- Em "Include in the home page", deixe só **Releases**; desmarque Packages e
  Deployments, que não são usados.

`portuguese` sai: o projeto não é mais só em português. `pt-br` fica enquanto as
regras estiverem escritas em português e houver o `README.pt-BR.md`; ele avisa o
visitante de fora e ajuda quem fala português a achar o projeto. Se as regras
passarem a ser escritas em inglês (veja [idiomas.md](idiomas.md)), reavalie.

O mesmo pela linha de comando, dentro da pasta do repositório:

```sh
gh repo edit \
  --description "Rules for T3 Code: you talk to one chat, the conductor. It opens a chat for each problem, keeps an eye on all of them and tells you what changed." \
  --add-topic t3-code --add-topic ai-agents --add-topic agents-md \
  --add-topic claude --add-topic codex --add-topic multi-agent \
  --add-topic orchestration --add-topic git-worktree \
  --add-topic developer-tools --add-topic pt-br \
  --remove-topic portuguese
```

## Imagem de prévia (Social preview)

É a imagem que aparece quando o link do repositório é compartilhado. O GitHub
aceita uma só, e ela fica em inglês.

1. Settings → General → Social preview → Edit → Upload an image.
2. Envie `docs/assets/social-preview.png` (1280 × 640, a mesma arte do banner, no
   tema escuro, com "RULES FOR T3 CODE" e "Talk to one chat. It conducts the
   rest.").

A versão em português, `docs/assets/social-preview-pt-br.png`, serve para
divulgar o projeto onde o público fala português, anexada à mão.

Cada PNG sai do SVG de mesmo nome. Para gerar de novo, abra o SVG num navegador
em 1280 × 640 e salve a captura.

## Banners do README

Ficam em `docs/assets/`, um par por idioma, e cada README usa o do seu idioma com
`<picture>` e `prefers-color-scheme`:

| Arquivo | Idioma | Tema |
|---|---|---|
| `banner-light.svg`, `banner-dark.svg` | inglês | claro, escuro |
| `banner-pt-br-light.svg`, `banner-pt-br-dark.svg` | português | claro, escuro |

Os SVGs são feitos à mão, sem fonte externa, e o `<title>` e o `<desc>` ficam no
idioma do arquivo. Ao mudar a frase de um, mude a do par e a da prévia social.

## Recursos da página

Em Settings → General → Features, desmarque **Wiki** e **Projects** se não forem
usados: a documentação mora no próprio repositório. Deixe **Issues** ligado, porque
é por lá que chegam as sugestões.

## Releases

Depois do merge na `main` e da tag `v2.0.0`, crie a release a partir da tag, com o
título "T3 Maestro 2.0.0" e, no texto, a seção da versão no `CHANGELOG.md`,
começando por "O que muda para quem já usa". Como o CHANGELOG está em português,
abra o texto com duas ou três linhas em inglês dizendo o que a versão traz. Marque
"Set as the latest release".

```sh
gh release create v2.0.0 --verify-tag --title "T3 Maestro 2.0.0" --notes-file <arquivo com a seção do CHANGELOG>
```

`--verify-tag` faz o comando parar se a tag ainda não existir na origem, em vez
de criar uma tag nova a partir da `main`.

## O que só o dono liga

Ajustes de segurança que nenhum commit faz. O modelo de ameaças
([seguranca.md](seguranca.md), [security.md](security.md)) conta com eles.

1. **Dois fatores na conta** (foto → Settings → Password and authentication), de
   preferência com chave de segurança. Por quê: quem entra na conta publica
   tags, e todas as cópias seguem as tags desta origem.
2. **Proteção da `main`** (Settings → Rules → Rulesets → New branch ruleset, alvo
   a branch padrão, ninguém na lista de exceção): exigir PR antes do merge,
   exigir os checks do CI, bloquear force push e bloquear a exclusão. Por quê:
   nada chega à `main` sem PR e sem CI verde, e o histórico publicado não é
   reescrito.
   Os checks, com os nomes exatos: `Privacidade`, `Base coerente`,
   `Testes (ubuntu-latest)`, `Testes (ubuntu-latest, CDPATH)`,
   `Testes (macos-latest)`, `Testes (macos-latest, CDPATH)`, `Shellcheck` e
   `Gitleaks`. Exija só depois de vê-los passar uma vez na `main`. O `Scorecard`
   fica de fora, porque só roda na `main`.
3. **Secret scanning e push protection** (Settings → Advanced Security, ou Code
   security): ligar os dois. Por quê: o GitHub barra o push que traz um segredo
   conhecido; o gitleaks do CI só o vê depois de enviado.
4. **Private vulnerability reporting**, na mesma página: ligar. Por quê: é o
   canal privado que o `SECURITY.md` indica; sem ele, não há onde relatar em
   particular.
5. **Tags `v*` protegidas** (Settings → Rules → Rulesets → New tag ruleset,
   padrão `v*`): um ruleset restringe a criação, só com o dono na lista de
   exceção; outro restringe atualização e exclusão, sem ninguém na lista. Por
   quê: só o dono publica versão, e uma tag publicada não muda de commit, que é
   o que as cópias conferem.
6. **Releases a partir da tag**, como em "Releases", acima, e "Releases
   imutáveis" se a opção aparecer (Settings → General → Releases). Se quiser,
   **tags assinadas** com `git tag -s`, com a chave pública cadastrada na conta.
   Por quê: a release mostra a tag que já existe, e a assinatura deixa cada
   pessoa exigir, com "Exigir tag assinada: sim" no `local/config.md`, que a
   versão venha da chave do dono, e não só da conta.
7. **Dependabot alerts e security updates** (Settings → Advanced Security):
   ligar. Por quê: avisam quando uma action usada tem falha conhecida; os PRs
   semanais de versão já vêm do `.github/dependabot.yml`.
8. **Permissões das Actions** (Settings → Actions → General): "Workflow
   permissions" em "Read repository contents", "Allow GitHub Actions to create
   and approve pull requests" desligado e aprovação para workflows de forks de
   quem contribui pela primeira vez. Por quê: workflow sem `permissions:` ou
   vindo de fork novo não ganha escrita no repositório.

Os selos do CI e do Scorecard estão comentados nos dois READMEs. Descomente
depois do primeiro push, trocando `<dono>/<repo>` pelo caminho do repositório:
o do CI quando o `CI` tiver rodado na `main`; o do Scorecard quando o
`Scorecard` tiver rodado na `main` e publicado a primeira nota.
