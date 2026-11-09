# Painel: tudo em uma tela

Use quando o dono escrever "painel" ou pedir uma visão geral. Só leitura.

## Levantar

Leia `estado.md`, cada chat que não está `encerrado`, e o estado real de cada PR,
CI e deploy citado. Nunca mostre dado não conferido; escreva "não sei".

## Mostrar

Página com `html_preview` e depois `html_render`, seguindo as regras visuais de
`explicar.md`, em uma coluna legível a partir de 360 px e nesta ordem:

1. **Depende de você:** cada decisão com a recomendação e o que muda. Se não houver,
   diga isso em uma frase. Não cobre o que estiver pausado.
2. **Em andamento:** título e o que está acontecendo em linguagem simples.
3. **Pausados:** só os títulos.
4. **Pronto hoje:** só o que foi concluído no dia.

Use cor só para estado, com as variáveis `--success`, `--warning`, `--destructive`
e `--info`, sempre acompanhadas de texto. Sem IDs, commits ou caminhos de arquivo.

Com interface `texto`, entregue as mesmas seções em lista curta, salvo se ele pedir
a página. Depois da página, escreva no máximo uma frase. Para as decisões, use "Mostrar em vez
de escrever" do `AGENTS.md`.
