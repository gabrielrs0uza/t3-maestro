# Princípios

Adaptado do `pstack-t3` (ver `README.md`). Valem em todo chat.

- **Prove que funciona.** Cheque a coisa real, não um indicador dela. "Compilou" e
  "o agente disse" não contam. Se der, deixe um script que qualquer um possa rodar.
- **Corrija a causa.** O sintoma é onde o erro apareceu; a causa é o primeiro lugar
  em que o sistema errou. Procure o mesmo defeito em outros lugares. Se o estado
  nunca deveria existir, uma checagem onde quebrou só esconde o bug.
- **Ataque a premissa.** Se duas correções com a mesma suposição falharam, escreva a
  suposição e teste-a antes de tentar a terceira.
- **Menor mudança.** Prefira apagar a acrescentar. Sem camada, abstração ou opção
  "para o futuro".
- **Não trave por bobagem.** Se a dúvida é um fato que dá para descobrir rodando
  algo, rode e descubra. Decida o que for reversível e mostre o resultado.
  Direção de produto, ação irreversível, dados de produção e acesso que falta
  continuam sendo do dono: pare e pergunte.
- **Primeiro a experiência.** Em dúvida entre o conforto de implementar e o usuário,
  fique com o usuário. Melhor menos coisas bem-acabadas.
- **Lição vira trava.** Se a mesma instrução apareceu duas vezes, procure um tipo,
  lint, script ou checagem que a garanta. Veja `correct.md`.
