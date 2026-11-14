# Ketchup: botar o dono em dia

Use quando ele perguntar "onde estávamos", "como tá", ou o equivalente no idioma
dele, ou ficar um tempo fora. Só leitura. Não abra chat, não envie ordem, não
altere nada.

## Levantar

1. Leia `local/estado.md`, as pautas com pedidos abertos e o diário depois de
   `Visto até`. Leia cada chat que não está `encerrado` só a partir do `Lido até`.
2. Confira o estado real de cada PR, CI e deploy citado.
3. Separe o que só ele pode decidir: escolha de produto, aprovação, ação
   irreversível ou acesso que falta. Inclua pendência antiga ainda sem resposta.
   Trabalho que você mesmo pode fazer não é pendência. Não invente pendência.

## Escrever

- Escreva no idioma de `local/config.md`, qualquer que seja o idioma das pautas,
  do diário ou dos intérpretes. Os títulos e frases daqui e de `pedidos.md` são
  exemplos em português; diga o equivalente.
- Comece com uma frase dizendo o que depende dele, ou que nada depende.
- Depois, o bloco "Desde a última vez" de `pedidos.md`, agrupado por projeto.
- Linguagem de conversa, como em "Como escrever para o dono" do `AGENTS.md`.
  Diga o que mudou para ele, não como foi feito. Sem hash, caminho, comando ou
  contagem de testes, salvo se ele precisar para agir.
- O que aconteceu: até 100 palavras, uma linha por assunto, dizendo se está
  pronto, rodando, falhou ou não foi verificado.
- Pendências: cada uma com cerca de 30 palavras, o bastante para ele decidir
  sem abrir nada: a decisão, sua recomendação, o que muda para o usuário e o risco.
  Nunca corte uma pendência para caber. Se houver pergunta, só uma, no fim.
- Nunca dê como pronto o que ainda depende dele. Escreva "não sei" no que não souber.

Depois de enviar, avance o `Visto até` em `local/estado.md`. É a única escrita
desta skill.
