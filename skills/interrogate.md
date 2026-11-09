# Interrogate: tentar quebrar a mudança

Revisão adversária. Só sobrevive o achado provado por execução. Reporte; não corrija.

## Escopo

O que foi pedido; se nada foi dito, o commit recebido contra a base dele. Antes
de começar, escreva em uma ou duas frases o que a mudança deveria fazer, a partir
do pedido, dos commits e da descrição. Se a intenção estiver confusa, pergunte.

## Tarefa

Quebre esta mudança. Prove cada achado rodando o código real: teste falhando,
script de reprodução ou saída de comando com o comportamento errado. Para um
plano ou design, rode um protótipo ou examine o código atual. Deixe as
reproduções na sua worktree e não faça commit nem push.

Para cada achado, dê: título, comando exato, saída obtida e saída esperada pela
intenção. Deixe de fora o que não rodou, inclusive estilo, nomes, estrutura e
riscos que só importam depois de uma mudança futura. Nenhum achado é um resultado
válido.

## Conferir

Rode de novo o comando de cada achado. Fica o que mostra a falha e contraria a
intenção. Junte os de mesma causa.

## Entregar

- Intenção: a frase do início.
- Achados: comando, saída e como contraria a intenção, ou "nenhum achado confirmado".
- Descartados: quantos e por quê.
