# Arena: várias tentativas, uma escolha

Use só quando o dono quiser explorar opções, ou confirmar com ele quando uma
tentativa só puder travar o caminho errado. Custa várias vezes mais: diga isso.

## Enquadrar

1. Diga o que cada tentativa deve produzir.
2. Defina de 3 a 6 critérios concretos de sucesso. Eles ficam com você, não vão
   para as tentativas.
3. Por padrão, 3 tentativas. Prefira executores diferentes quando importar julgamento.

## Rodar

Abra um chat por tentativa com `t3_thread_launch`, cada um em sua worktree, todos
com o mesmo pedido. Cada um entrega o resultado, o motivo e o que descartou, sem PR.

## Julgar

Com todas prontas, abra um chat de outra família de modelo, só leitura, com os
critérios e as tentativas. Ele pontua cada critério e recomenda uma base. Leia as
tentativas e compare. Se discordarem, leia os dois motivos.

Se a escolha for visual ou de produto, quem decide é o dono: mostre as opções
com sua recomendação, comparáveis no mesmo lugar e com os mesmos dados.

## Juntar

Escolha a base mais fácil de manter e traga dela para a frente só o melhor das
outras, normalmente uma ou duas coisas de cada, dentro de uma ideia coerente. Se
tudo convergir, é sinal forte. Se divergir muito, o pedido estava vago: refaça.

## Fechar

Verifique o resultado final como qualquer entrega. Informe a base e o motivo, o
que veio de cada tentativa e o que foi descartado. Encerre os chats perdedores
seguindo "Encerrar um chat" do `AGENTS.md`.
