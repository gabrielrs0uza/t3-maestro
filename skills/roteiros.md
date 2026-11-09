# Roteiros por tipo de tarefa

Adaptado dos playbooks do `pstack-t3` (ver `README.md`). Siga o roteiro indicado
no pedido. Ele não substitui as proibições do pedido, e os princípios estão em
`principios.md`, nesta mesma pasta.

Comece dizendo, com suas palavras, qual é o objetivo e a menor mudança que o
atende. Não espere confirmação, salvo se a evidência mostrar que o pedido parte de
uma premissa errada: aí mostre e pare.

## Bug

Cada linha entregue vem de evidência, não de "pode ajudar".

1. Reproduza você mesmo, no mesmo lugar em que o problema acontece. Só peça ajuda
   dizendo o motivo exato de não conseguir chegar lá.
2. Liste hipóteses e elimine com evidência, sempre pelo teste que mais corta
   possibilidades. Na dúvida, instrumente e leia o estado real.
3. Corrija a causa, não o sintoma. Se a evidência derrubar uma hipótese, desfaça
   o que veio dela. Entregue a menor mudança que a evidência justifica.
4. Verifique no mesmo lugar da reprodução. "Inconclusivo" não é aprovado.
5. Se houver teste barato, o teste falhando entra antes da correção no histórico.

Entregue: o que quebrou, a causa, a correção, e a saída real falhando e depois passando.

## Funcionalidade

1. Entenda o subsistema afetado antes de desenhar.
2. Escolha primeiro a forma dos dados: máquina de estados em vez de booleanos
   soltos, tabela em vez de `if` encadeado, tipo em vez de suposição repetida.
3. Antes de dividir o trabalho, escreva: o que bloqueia o resto, o que pode correr
   em paralelo, o que é compartilhado e a menor divisão segura. Se um trabalhador
   só for melhor, diga por quê.
4. Implemente em commits pequenos e em ordem, cada um verificado.
5. Verifique usando a funcionalidade de verdade.

Entregue: o que foi feito, o que escolheu e por quê, e as decisões em aberto.

## Refatoração

A estrutura muda; o comportamento, não. Se aparecer bug ou recurso faltando, separe.

1. Fixe o comportamento atual antes de mover qualquer coisa: teste de
   caracterização, snapshot ou comparação. Tipos e lint não contam.
2. Diga como a estrutura deveria ser se fosse feita hoje.
3. Tire antes de pôr: código morto, wrappers de um chamador só, validação redundante.
4. Mova em passos pequenos, sempre com o teste verde. Ao mudar uma API, migre todos
   os chamadores e apague a antiga na mesma leva. Confira renomeações nos arquivos.
5. Prove que nada mudou no produto real, não só que compila.
6. Se o código não ficou mais fácil de ler, desfaça.

Entregue: o que mudou, a comparação de antes e depois e o que foi descartado.

## Investigação

Só leitura. O resultado é uma explicação com fontes ou uma recomendação.

Separe confirmado de hipótese, cite arquivo e linha ou a consulta usada, e dê sua
opinião com os motivos. Se a premissa do pedido estiver errada, diga.

## Protótipo

Serve para decidir, é descartável e não é a entrega final.

1. Diga qual decisão ele ajuda a tomar. Sem decisão, não há protótipo.
2. Faça rápido, isolado do código de produção e invisível para alunos. Qualidade de
   código não importa aqui.
3. Compare as alternativas atrás de um seletor, cada uma com nome, usando os mesmos
   dados fictícios.
4. Verifique olhando cada variação de verdade.
5. Apresente as opções, os prós e contras e sua recomendação.

A implementação real depois segue o roteiro de funcionalidade.
