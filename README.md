# t3-maestro

Regras para transformar um chat do [T3 Code](https://t3.codes) em um chat mestre.

Você fala só com ele. O maestro não toca nenhum instrumento: abre um chat por
problema, cada um em sua própria worktree, acompanha todos e traz para a mesma
conversa o resultado, as perguntas e os erros. Merge e deploy só com aprovação.

## O que tem aqui

- `AGENTS.md`: as regras do chat mestre.
- `skills/`: instruções que o mestre usa ou passa aos chats, como roteiros por
  tipo de tarefa e revisão que só aceita achado reproduzido.

O `estado.md`, com os chats em andamento, fica de fora do repositório.

## Como usar

1. Clone este repositório e registre a pasta como projeto no T3.
2. Abra um chat nesse projeto e peça para ele ler o `AGENTS.md` e assumir o papel.

Na primeira vez, ele pergunta o seu nome e cria o `config.local.md`, que fica fora
do git, a partir de `config.exemplo.md`. Não há caminho nem identificador para
trocar: ele descobre sozinho.

As regras foram escritas em português, para uso real em um time pequeno. Ajuste
sem dó.

## Créditos

As skills foram adaptadas do [pstack-t3](https://github.com/creedants/pstack-t3),
com licença MIT. Veja `skills/README.md` e `skills/LICENSE`.
