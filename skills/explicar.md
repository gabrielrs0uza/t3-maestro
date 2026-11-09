# Explicar: desenhos grandes, poucas palavras

Use quando o dono pedir para entender algo, escrever "eli5", ou quando "O momento
certo" do `AGENTS.md` indicar. Explique para quem não sabe nada do assunto. Só leitura: não altere arquivos nem abra chats.

## Entender primeiro

Se o tema for do código ou dos dados, leia a fonte real antes de desenhar. Nunca
invente número, tela ou comportamento. Se a explicação depender de uma simplificação,
ela não pode deixar a pessoa com uma ideia errada.

## Montar

- De 3 a 7 cenas, na ordem em que a coisa acontece. Uma ideia por cena.
- Cada cena tem um desenho grande em SVG e no máximo 12 palavras.
- Use comparação com o dia a dia e mantenha a mesma ao longo de todas as cenas.
- Sem jargão. Se um termo for inevitável, explique-o na própria cena.
- A última cena diz o que a pessoa precisa lembrar.

## Mostrar

Página única, sem dependências externas, em largura fluida e legível a partir de
360 px. Sem fundo na página, moldura externa ou título grande. Use as variáveis de
tema do T3 (`--foreground`, `--muted`, `--primary`, `--border` e as demais), nunca
cores fixas.

1. Confira com `html_preview`, em largura 390 e 728, nos temas claro e escuro.
2. Mostre com `html_render`, usando o `contentHeight` retornado.
3. Depois da página, escreva só uma frase oferecendo aprofundar. Não repita o conteúdo.

Com interface `texto`, só gere a página se ele escrever "eli5" ou pedir desenho. Sem
página, ou se `html_render` não estiver disponível, explique em texto, com a mesma
estrutura.
