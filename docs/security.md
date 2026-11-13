# Updater security

**English** · [Português](seguranca.md)

What `scripts/maestro.sh atualizar` (update) and `voltar` (go back) do to each
person's copy, what they never do, what the owner controls and what is left
unprotected. To report a vulnerability, see [`SECURITY.md`](../SECURITY.md).

In short: a new version is checked by the script that is already installed,
without running anything that came with it. Only documentation goes in on its
own; everything else waits for the owner to read it and confirm. What belongs to
the person, in `local/`, never goes into git and is never overwritten.

## What the updater never does

- Run downloaded code before the owner accepts the version. A migration is data,
  read by the installed script; downloaded shell never runs.
- Apply a rule, skill, script, migration, test or CI change without the owner's
  confirmation.
- Put `local/` into git, overwrite a local file or delete anything of the
  person's.

## What it does

Each copy is a git clone, and the base moves from tag to tag (`vX.Y.Z`). For each
new version:

1. **Checks it before any merge, with the script already installed.** Code from
   a version only runs after that version has been applied.
2. **Applies on its own only documentation**, from a flat, closed list, as
   regular files (not executable, not symbolic links):
   - `README.md` and `README.<language>.md` at the root, `CHANGELOG.md`,
     `LICENSE`, `ORIGEM.md` and `VERSION`;
   - `docs/<name>.md`, directly in `docs/`, no subfolders;
   - images in `docs/assets/`.

   A path with a component that starts with `.` never counts as documentation,
   and neither does an agent instruction file name (`AGENTS*`, `CLAUDE*`,
   `GEMINI*`, `SKILL.md`, `.cursorrules` and the like), in any letter case.
3. **Asks the owner for one confirmation for everything else:** `AGENTS.md`,
   inside or outside the fixed block, `CLAUDE.md`, skills, `config.exemplo.md`,
   migrations, scripts, tests, CI, `SECURITY.md` itself and any other file. The
   owner sees the summary, the file list and the full diff, made with
   `git diff --text` and kept in `local/atualizacao-pendente.diff`; a change to
   the fixed block is highlighted. The acceptance holds only for that tag, that
   commit and the hash of that diff.
4. **Refuses, even with acceptance** (`versao-invalida`):
   - a tag whose `VERSION` does not match its name;
   - a file name outside `[A-Za-z0-9._/-]`;
   - a migration outside the closed vocabulary, with a symbolic link in its path
     or with a source that is not a regular file;
   - a path that, in lowercase, starts with `local/` or is `config.local.md` or
     `estado.md`, before or after the merge;
   - a text file with a control character (NUL, stray CR, ESC, C1), a bidi or
     zero-width character, a BOM, or a line over 2000 bytes: any of these could
     hide text in the diff;
   - `.gitattributes` or `.lfsconfig`, in any folder and any letter case:
     filters, `diff=`, `-diff` and LFS would make the diff show one thing and
     the disk keep another.

   The diff and the merge run with system and user attributes neutralized,
   without textconv and without an external diff.

   A version that would overwrite a local file outside git gives `colisao`
   (collision) and does not go in.
5. **Pins the origin and the tags.** The origin's address is recorded on the
   first update. A different origin gives `origem-mudou`; an applied tag that
   moves to another commit, `tag-movida`; a history that does not descend from
   the installed one, `historico-divergente`. Signed tags are optional ("Exigir
   tag assinada" in `local/config.md`). `ls-remote` and the tag's `git fetch` have
   the same limits: no password prompt, a connection timeout, a speed limit,
   and a stalled ssh connection is dropped.
6. **Backs up everything local** before changing the base, in
   `local/backups/<date>-<from>-para-<to>/`: `local/` and the files at the root
   that git does not track, ignored ones included. Inside `local/`, a symbolic
   link is copied as a link; for the root files, the backup follows the link and
   keeps the target's content (see "Known limits").
7. **Survives interruption and repetition.** Update and go-back record each
   phase and resume where they stopped, and every new name is unique. While the
   process that holds the lock is alive, checked by its PID and start time, the
   result is `ocupado` (busy), with no age limit; the lock is taken over only
   once that process has died. The test
   hook `MAESTRO_PARAR_EM` is read only from the process environment: a new
   version cannot set it without going through the owner's confirmation.
8. **Goes back on request:** `scripts/maestro.sh voltar local/backups/<folder>`
   restores the base and `local/` to what they were. The state before going back
   is kept in another backup, and the abandoned version does not come back on
   its own.

## What the owner controls

- **The fixed approvals.** The fixed block of `AGENTS.md` requires the owner's
  approval for merge, deploy, changes to production data and deletions. The
  configuration, `local/` and skills can only add approvals. A version that
  touches this block goes in only with the owner's confirmation, with the
  block's diff highlighted.
- **Each version that needs confirmation.** The conductor asks once, "update to
  vX?"; without a yes, nothing changes.
- **Automatic updates** ("Atualização automática: não" turns them off), the
  channel, requiring signed tags and going back.
- **On GitHub**, the settings no commit can make are listed in
  [O que só o dono liga](pagina-github.md#o-que-só-o-dono-liga) (in Portuguese).

## Known limits

- **Trust on first use.** The recorded origin is the remote's address on the
  first update; if it was already wrong, the script trusts it.
- **It depends on the account that publishes the tags.** Whoever controls that
  account can publish a version. Only documentation would go in on its own, but
  the rest reaches the owner as a legitimate request. Signed tags narrow this
  for those who require them.
- **Rules are text for an agent with broad access.** The script shows
  everything, but it does not read for the owner: the owner should read what
  they accept. The script also cannot tell the owner from the agent when it
  receives `--aceitar`; the barrier is the written rule and the confirmation in
  the chat.
- **Documentation that goes in on its own can mislead a person**, but it does
  not become a rule for the agent, which does not follow `README`, `docs/` or
  `CHANGELOG` as orders.
- **No protection against someone who already controls the machine or the local
  git:** the installed script, the git config, `local/versao.md` or the
  credentials.
- **`SECURITY.md` is not on the documentation list**, so a version that changes
  it needs confirmation.
- **Backups are not encrypted:** `local/backups/` has the machine's protection.
- **A hash is not a secret:** someone with a guess can confirm whether a term is
  on the forbidden-terms list, and the privacy check only catches what is on it.
- **The test hook `MAESTRO_PARAR_EM` is still in the script.** It stops the
  update at a chosen point and is read only from the process environment. A new
  version cannot set it without going through the owner's confirmation.
- **The backup keeps more than `local/`.** It also copies the root files git
  ignores, such as `.claude/`, and, for those, follows symbolic links: it keeps
  the target's content, not the link. Everything stays in `local/backups/`, on
  the machine itself.

## For 2.1

What is left for the next version, with no date set:

- Keep `MAESTRO_PARAR_EM` read only from the process environment and
  documented, as it is today.
- In the backup, copy symbolic links as links and review copying the ignored
  root files.

## What the tests prove

Two suites, in temporary folders and without network:

- `tests/atualizacao.sh`, scenarios (a) to (z), with synthetic origins. Run
  `bash tests/atualizacao.sh --verboso`. Every command runs with
  `CDPATH=.:/tmp`.
- `tests/privacidade.sh`, the privacy check with made-up terms: upper case, no
  accents, combining accents (NFD), a term inside a word, between hyphens or
  underscores, phrases, the owner's name and a clean text.

| What the scenario proves | Scenarios |
|---|---|
| Only documentation goes in on its own; a fixed rule, a rule outside the block, a skill and a script need the owner's ok | (a), (i) `script`, (s) `regra` |
| Documentation in an executable file needs the ok | (i) `exec` |
| Nothing from the new version runs before acceptance: a shell migration, a new library | (i) `shell`, `lib` |
| A migration outside the vocabulary is refused, even with acceptance | (i) `base`, (s) |
| A migration facing a symbolic link, a dangling link and a special file | (r) |
| A version that tracks `local/provas/` is refused, even with acceptance; collision with an ignored file | (k) |
| A name with a space, in a migration and in a script | (p), (q) |
| `VERSION` different from the tag | (o) |
| The full diff is kept to the last line; acceptance applies what was kept | (q) |
| Changed origin, tag moved after being shown, unsigned tag when a signature is required | (j) |
| Own commits in the copy; base changed in the copy | (g), (e) |
| Backup with `local/`, evidence and root files | (b), (k) |
| Interruption, resuming, two runs in the same second, interrupted go-back | (c), (l), (m), (n) |
| Going back without the abandoned version returning on its own | (h), (m) |
| Automatic updates off, candidate channel, no network | (f), (d) |
| Agent instructions disguised as documentation, in a subfolder, behind a dot or in another case; a subfolder in `docs/` | (t) |
| A path of the person's in another case (`Local/`, `Estado.md`), even with acceptance | (u) |
| A text file with a NUL byte, even with acceptance | (v) |
| Stray CR, ESC, bidi, zero-width and a huge line, even with acceptance | (w) |
| `.gitattributes` with `filter=`, `-diff` and `diff=`, in any folder and case, and `.lfsconfig`, even with acceptance; a filter in the user's attributes does not change what is written | (x) |
| An old lock whose owning process is alive gives `ocupado`; once it dies, the update resumes | (y) |
| The tag's `fetch` with the network limits | (z) |

No scenario in this suite, so these rest on the code alone: the diff hash on
acceptance, symbolic links and gitlinks in documentation, the `ls-remote`
network limits and `MAESTRO_PARAR_EM` coming from a new version.

## What CI checks

- `.github/workflows/ci.yml`, on every push and pull request: `Privacidade`
  (`scripts/checar-privacidade.sh` and `tests/privacidade.sh`), `Base coerente`
  (`scripts/checar-base.sh`), `Testes` (`tests/atualizacao.sh` on Ubuntu and
  macOS, with and without an exported `CDPATH`), `Shellcheck` (fails from
  `warning` up) and `Gitleaks` (the whole history).
- `.github/workflows/scorecard.yml`: OpenSSF Scorecard on the default branch
  only, weekly, on every push to `main` and when branch protection changes. It
  publishes the score, which feeds the badge, and sends the SARIF to Code
  scanning.
- `.github/dependabot.yml`: one pull request a week to update the actions.
- `permissions: contents: read` at the top and in every job; only Scorecard has
  `security-events: write` and `id-token: write`. Actions pinned by full commit
  SHA, with the version in a comment, and checkout without stored credentials.
  Shellcheck and gitleaks come from the official releases, checked by SHA-256.
- The SHA pins Scorecard's `action.yaml`, but not the Docker image it pulls,
  which comes from the action's own tag.
