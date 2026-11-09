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

Na primeira vez, ele faz algumas perguntas e se adapta a você: idioma, estilo, se
prefere desenhos ou texto, o que costuma fazer e o que nunca pode acontecer sem sua
aprovação. Serve para quem programa e para quem não programa. As respostas ficam em
`config.local.md`, fora do git.

Peça "painel" para ver tudo em uma tela, ou "eli5" e um tema para entender algo com
desenhos, direto na conversa.

As regras foram escritas em português, para uso real em um time pequeno. Ajuste
sem dó.
