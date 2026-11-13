# Security policy

T3 Maestro is a set of rules in Markdown for agents, plus a small bash updater
that runs on each person's machine. This file explains how to report a
vulnerability, what is in scope and what to expect. The threat model is in
[docs/security.md](docs/security.md) (English) and
[docs/seguranca.md](docs/seguranca.md) (Portuguese). This policy in Portuguese
is [at the end](#em-português).

## Reporting a vulnerability

Report privately through GitHub: open the **Security** tab of this repository
and choose **Report a vulnerability**. Do not open a public issue, pull request
or discussion about a vulnerability, and do not look for a personal e-mail
address: there is none for this.

If that button is missing, private reporting is not turned on yet. Open a public
issue that only asks for a private channel, with no details about the problem.

A useful report has:

- the version (the `VERSION` file or the tag);
- what an attacker needs: push access to the origin, a file on the machine, a
  crafted tag, and so on;
- steps to reproduce, ideally as a scenario in the style of
  `tests/atualizacao.sh`;
- the impact.

Leave out personal data, real machine paths and secrets.

## Scope

In scope:

- **The updater:** `scripts/maestro.sh` and `scripts/lib-maestro.sh`. This
  covers what it accepts from the origin, what it runs, what it applies without
  the owner's confirmation, and what it does to `local/`, including backups,
  going back and the lock.
- **Migrations:** the declarative interpreter and its closed vocabulary in
  `migracoes/`.
- **The privacy check:** `scripts/checar-privacidade.sh` and the hashed list of
  forbidden terms, including personal data that reached tracked files.
- **The fixed rules:** the fixed block of `AGENTS.md`, and `CLAUDE.md`. In scope
  is any way to make an agent that follows these rules merge, deploy, delete or
  change production data without the owner's approval. So is any way to apply a
  new version without the owner's confirmation when that version needs it.
- **The CI workflows** in `.github/workflows/` and `.github/dependabot.yml`.

Out of scope:

- T3 Code, the agents and their hosts. Report those to their maintainers.
- An attacker who already controls the machine, the local git configuration or
  the credentials.
- Changes a person makes to their own copy.
- The known limits listed in the threat model, unless the report gets past them
  in a way the document does not describe.

## Supported versions

| Version | Supported |
|---|---|
| Latest stable release (newest `vX.Y.Z` tag) | Yes |
| Older releases, release candidates (`-rc`), `main` | No |

Fixes ship as a new stable release. A fix that touches scripts, rules, CI or
this file is applied to a copy only after the person who owns that copy
confirms it, like any version that is not documentation alone.

## What to expect

The project is maintained on a best-effort basis, with no guaranteed response
time. What you can expect:

- the report is read and answered in the private advisory;
- if it is confirmed, the fix comes with a new stable release and, when the
  problem can be reproduced there, a scenario in `tests/`; the advisory is
  published after that release, with credit if you want it;
- if it is not accepted, the advisory says why.

---

## Em português

**Como relatar:** em particular, pela aba **Security** deste repositório, em
**Report a vulnerability**. Não abra issue, PR ou discussão pública sobre uma
vulnerabilidade, e não procure e-mail pessoal: não há um para isso. Se o botão
não aparecer, o relato privado ainda não foi ligado: abra uma issue pública
pedindo um canal privado, sem detalhes do problema. Diga a versão, o que o
atacante precisa, os passos para reproduzir (de preferência como um cenário no
estilo de `tests/atualizacao.sh`) e o impacto. Não mande dados pessoais,
caminhos reais de máquina nem segredos.

**Escopo:** o atualizador (`scripts/maestro.sh`, `scripts/lib-maestro.sh`),
inclusive o que ele aplica sem a confirmação do dono; as migrações; a checagem
de privacidade; as regras fixas (bloco fixo do `AGENTS.md` e o `CLAUDE.md`); e
os workflows de CI e o `.github/dependabot.yml`. Ficam de fora o T3 Code e os
agentes, quem já controla a máquina, o config local do git ou as credenciais,
mudanças que a pessoa faz na própria cópia e os limites conhecidos do modelo de
ameaças ([docs/seguranca.md](docs/seguranca.md)), salvo se o relato for além
deles.

**Versões:** só a estável mais nova recebe correção. A correção sai como versão
estável nova; se mexer em script, regra, CI ou neste arquivo, espera a
confirmação do dono em cada cópia, como toda versão que não é só documentação.

**Resposta:** sem prazo garantido. O relato é lido e respondido no aviso
privado. Se for confirmado, a correção sai numa versão estável nova e, quando o
problema puder ser reproduzido em `tests/`, com um cenário de teste; o aviso é
publicado depois dela, com crédito se você quiser. Se não for aceito, o aviso
diz o motivo.
