# Painel: tudo em uma tela

Use quando o dono escrever "painel", o equivalente no idioma dele, ou pedir uma
visão geral. Só leitura.

## Levantar

Leia `local/estado.md`, as pautas com pedidos abertos, o diário depois de
`Visto até`, cada chat que não está `encerrado` e o estado real de cada PR, CI e
deploy citado. Nunca mostre dado não conferido; escreva "não sei".

## Mostrar

Página com `html_preview` e depois `html_render`, seguindo as regras visuais de
`explicar.md`, em uma coluna legível a partir de 360 px. A página inteira sai no
idioma de `local/config.md`, com o atributo `lang` dele, inclusive os títulos
abaixo, que são exemplos em português. Nesta ordem:

1. **Depende de você:** cada decisão com a recomendação e o que muda. Se não houver,
   diga isso em uma frase. Não cobre o que estiver pausado.
2. **Desde a última vez:** o bloco de `pedidos.md`, por projeto.
3. **Em andamento:** por projeto, cada pedido aberto em linguagem simples.
4. **Pausados:** só os títulos.
5. **Pronto hoje:** só o que foi conferido no dia, marcando o que foi publicado.

Depois de mostrar, avance o `Visto até` em `local/estado.md`.

Use cor só para estado, com as variáveis `--success`, `--warning`, `--destructive`
e `--info`, sempre acompanhadas de texto. Sem IDs, commits ou caminhos de arquivo.

Com interface `texto`, entregue as mesmas seções, no mesmo idioma, em lista
curta, salvo se ele pedir a página. Depois da página, escreva no máximo uma frase.
Para as decisões, use "Mostrar em vez de escrever" do `AGENTS.md`.
