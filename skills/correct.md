# Correct: tornar impossível o erro repetido

Só para código em repositório. Use quando o dono corrigir duas vezes o mesmo tipo
de erro num repo, ou quando ele pedir. É trabalho de código: vai para um intérprete e segue "Caminho até o
merge". Primeiro traga a proposta; só implemente depois do ok dele.

Considere que todo colaborador é um agente que só vê os arquivos que abriu, copia
o exemplo mais próximo e pega o caminho mais curto que compila.

## Achar as classes de erro

Leia commits recentes, reverts, comentários de revisão, regras de agentes e
comentários explicando gambiarras. Agrupe os erros. Uma classe conta quando
aconteceu duas vezes.

## Corrigir no nível mais alto que funcione

1. Arquitetura: um dono para cada estado, um jeito suportado para cada tarefa, e
   apagar o caminho antigo que um agente copiaria.
2. Tipos, para o estado ruim não poder ser escrito. Se ainda compilar, um lint ou
   checagem no CI cujo erro diga o que usar no lugar.
3. Teste de comportamento. Conserte ou apague teste que passa com o comportamento quebrado.
4. Regra escrita por último, só para julgamento: nada falha quando alguém a ignora.

## Provar

Uma correção por commit. Prove que cada checagem falha num erro real do passado,
com o mesmo comando local e no CI.

## Entregar

Cada classe com a evidência, o nível escolhido e por que um nível acima não serviu.
