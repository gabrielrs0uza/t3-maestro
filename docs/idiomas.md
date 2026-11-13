# Em que idioma escrever as regras

Premissa: tudo o que o maestro diz ao dono já sai no idioma do campo **Idioma** de
`local/config.md`, inclusive os rótulos que as regras usam ("Anotei", "conferi
agora", os estados dos pedidos). A apresentação já está em dois idiomas
(`README.md` em inglês, `README.pt-BR.md` em português). A decisão em aberto é só
uma: em que idioma ficam escritas as **regras**, `AGENTS.md` e `skills/`, que
somam cerca de 13 mil palavras (o `AGENTS.md` tem cerca de 4 mil; as skills, cerca
de 9 mil).

## O que já não depende de idioma

- **Checagem de privacidade:** compara o hash de cada palavra normalizada. Vale
  para qualquer idioma, sem mudança.
- **Tarefas das migrações:** são códigos fechados (`MONTAR_PAUTAS`,
  `AVISAR_ATUALIZACAO`, `PERGUNTAR_PARALELO`, `CRIAR_ROTINA_ATUALIZACAO`). O
  maestro lê o código e conta ao dono no idioma dele.
- **Resultados do atualizador:** também são códigos (`em-dia`, `precisa-aceite`,
  `base-alterada`...), que as regras explicam.
- **Config:** o campo **Idioma** já existe; nenhuma opção abaixo pede campo novo,
  salvo a (c), se a escolha da árvore não vier do próprio Idioma.

## O que prende as regras ao português

São nomes que os scripts e as pessoas já guardam. Mudá-los é mudar formato:

- **Campos do config**, lidos pelo nome: "Atualização automática", "Canal",
  "Origem das atualizações", "Exigir tag assinada", "Abrir chats sem perguntar", e
  valores como `sim`, `não`, `estável`. Trocar exige migração e script novo.
- **`local/versao.md`** ("Base", "Formato local", "Commit aplicado", "Última
  checagem") e as colunas de `local/estado.md` ("Lido até", "Último aviso").
- **Rotinas já criadas:** o `prompt` de cada uma cita uma seção do `AGENTS.md`
  pelo título ("siga a seção "Rotina" do AGENTS.md"). Se o título mudar, a rotina
  de quem já usa aponta para uma seção que não existe.

Em qualquer tradução, o mais seguro é tratar esses nomes como identificadores:
ficam em português, entre crases, como nomes de arquivo.

## As opções

### (a) Regras só em português, como hoje

- **Prós:** custo zero. Quem mantém escreve na própria língua e revisa o sentido de
  cada regra, inclusive do bloco fixo, sem intermediário. Nenhuma versão nova,
  nenhuma confirmação para ninguém.
- **Contras:** quem chega de fora entende o projeto pelo README, mas não consegue
  ler nem propor mudança nas regras sem traduzir. O mesmo texto costuma gastar mais
  tokens em português do que em inglês, e o `AGENTS.md` é lido a cada conversa.

### (b) Regras em inglês como fonte única

O idioma da conversa continua vindo do config.

- **Prós:** uma fonte só, legível para qualquer contribuidor. Os rótulos viram
  inglês e o maestro os traduz para o dono, como já faz hoje no sentido contrário.
  Em geral, menos tokens por conversa.
- **Contras:** quem mantém passa a revisar regra de aprovação numa segunda língua.
  Traduzir muda o bloco fixo, então o atualizador para em cada cópia: cada pessoa
  confirma uma vez, com o diff do bloco destacado, e a troca vira versão **MAJOR**.
  Os identificadores da lista acima ficam em português dentro do texto em inglês,
  ou mudam com migração, script novo e rotinas recriadas.

### (c) Duas árvores traduzidas, com checagem de paridade no CI

- **Prós:** cada pessoa lê as regras na sua língua.
- **Contras:** Claude e Codex carregam o `AGENTS.md` da raiz (o `CLAUDE.md` só o
  importa). Escolher a árvore pelo idioma pede um `AGENTS.md` que só aponta para
  outra pasta, e aí as regras deixam de entrar sozinhas no contexto e dependem de o
  agente seguir o ponteiro, inclusive depois de a conversa ser resumida. Toda mudança
  de regra vira duas. A paridade no CI confere estrutura (mesmos títulos, arquivos,
  marcadores e identificadores), não sentido; duas versões do bloco fixo podem
  divergir em uma aprovação sem o CI ver. A `checar-base.sh` e as citações
  `skills/x.md` precisam ser refeitas para duas pastas.

## Esforço estimado

| Opção | Na troca | Depois |
|---|---|---|
| (a) | nenhum | manter os dois READMEs iguais a cada versão |
| (b) | 2 a 4 dias: traduzir as 13 mil palavras com ajuda de um modelo, revisar frase a frase o bloco fixo e as aprovações, ajustar `docs/cenarios.md`, o teste e o CHANGELOG, e lançar uma MAJOR | igual a hoje |
| (c) | 4 a 6 dias: o mesmo da (b), mais o ponteiro por idioma e o script de paridade | cada mudança de regra custa quase o dobro, para sempre |

## Recomendação

Ficar com **(a)** agora e planejar **(b)** como a próxima versão MAJOR quando
aparecer contribuição de quem não lê português, mantendo em português, como
identificadores, os campos do config, os formatos de `local/` e os títulos que as
rotinas citam. Não seguir a (c): o custo de manter duas versões do bloco fixo
iguais em sentido é maior que o ganho, já que o dono não precisa ler as regras
para usar o maestro.
