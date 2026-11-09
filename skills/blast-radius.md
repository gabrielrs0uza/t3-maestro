# Blast radius: o que esta mudança quebra em outro lugar

Listar quem chama a função não é o trabalho. O trabalho é achar a quebra que uma
busca de texto não mostra. Um texto convincente não vale nada: prove rodando.

## Quão certo você está

Leve cada fato de que a segurança depende o mais fundo que for barato, e diga
até onde chegou:

1. Você disse. Não vale sozinho.
2. Apontou a linha real, ou o código da biblioteca.
3. Mostrou, passo a passo, que o caso ruim não acontece.
4. Rodou: um script ou teste chamando o código real, que falha se você errou.
5. Reproduziu no app rodando.

## Passos

1. Leia a mudança: o que ela adiciona, altera e apaga, e o que passa a fazer
   diferente, inclusive o que o diff não mostra.
2. Ache o único fato que torna a mudança segura. Gaste o tempo aqui.
3. Olhe onde a busca para: testes e2e que dependem do comportamento antigo,
   código da biblioteca na versão fixada, ordem de execução, JSON de API, coluna
   de banco, flag, permissão, outro app lendo o mesmo dado, e o código três
   passos adiante.
4. Para cada risco, diga a chance real e o custo real. Separe confirmados de
   checados e descartados. Nunca invente chamador ou API.
5. Prove o fato com um script ou teste e cole o resultado.

## Entregar

- O que a mudança faz, incluindo o não óbvio.
- O fato que a torna segura, até onde chegou e a prova, ou "não provado".
- Riscos: como quebra, arquivo e linha, chance, gravidade e como checar.
- Descartados: o que foi checado e por que está ok.
- Antes do merge: o teste mais barato que pega o problema real.
