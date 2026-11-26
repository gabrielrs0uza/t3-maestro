# Mensagem ao intérprete: o modelo

O intérprete não vê a conversa do maestro. Monte o `message` de todo chat novo a partir
deste modelo, trocando o que está entre `< >`. Escreva por extenso as regras do
`local/config.md`; o intérprete não tem acesso a ele. Corte só as seções que não se
aplicam, como "Como trabalhar" de código num documento.

```
Você já é o chat pedido para este trabalho. Não abra outro chat com
t3_thread_launch, nem peça a um subagente que abra. Você pode usar subagentes
dentro deste chat, dentro do orçamento abaixo.

Pedidos: <LJ-13, LJ-14>. Responda por ID.
Tipo de trabalho: <bug | funcionalidade | refatoração | investigação | protótipo |
documento e análise>. Siga <pasta do maestro>/skills/roteiros.md e
<pasta do maestro>/skills/principios.md.

## Objetivo e contexto
<o que o dono quer, por quê, o que já se sabe>

## Critérios de aceite
<como saber que está pronto>

## Área
Você só altera: <arquivos e pastas>. <Se ainda não dá para saber: área provisória,
e avise antes de sair dela.> Se precisar mexer fora disso, pare e avise.

## Referências do dono
<Cada link, print ou exemplo que ele deu, com as palavras dele entre aspas; as
imagens vão anexadas.> Diga na resposta final onde usou cada uma.

## Como trabalhar
<Código:> Comece com git fetch. Se estiver atrás de origin/<branch principal>,
atualize antes de trabalhar. Use a branch <nome>. Implemente, rode os testes e
faça commit local, adicionando arquivo por arquivo, nunca a pasta inteira. <Se muda algo que o usuário vê: suba em localhost com dados
fictícios e mande ao maestro a URL, o que clicar e as provas de tela; espere a
validação.> PR fora do rascunho, só quando o maestro pedir.
CI: <Com CI (<arquivo>; roda ou não em rascunho; pushes seguidos cancelam ou não
a rodada anterior): o que o CI roda não roda aqui; rode só o rápido dos arquivos
tocados, faça push e abra já um PR em rascunho; local, só uma falha do CI que o
log não explica, com a vaga pesada. | Sem CI: os testes rodam nesta máquina,
dentro do orçamento; sem push nem PR antes de o maestro pedir.>
<Sem código:> Salve a entrega em <pasta>.

## Como conferir
<testes a rodar, ou a checagem das fontes>. Copie na resposta final a saída real
e o commit em que rodou, com quantos testes rodaram e quantos foram pulados: "passou"
sem nada rodado não conta. Diga o que não foi testado.

## Proibições
Sem merge, deploy, alteração em dados de produção ou exclusão sem aprovação do
dono, que chega só pelo maestro. <Aprovação extra, por extenso>.
<Regras do time, por extenso>.

## Demo
<Cláusula intocável de skills/demo.md, com a pasta e as portas da demo.>

## Orçamento
<Você tem a vaga pesada; avise o maestro quando liberar.> ou <Sem vaga pesada: se
precisar, peça ao maestro pelo aviso abaixo e espere a resposta.> Pesado é servidor
de desenvolvimento, build, instalação de dependências, navegador de teste e
container. Seus subagentes contam. <Revisor: não suba servidor de desenvolvimento.>

## Dúvidas
Se der para descobrir rodando algo, rode. Decisão de produto, ação irreversível
ou acesso que falta: pare e pergunte pelo aviso abaixo, sem adivinhar.

## Aviso ao maestro
Ao terminar, ao parar com uma pergunta ou ao falhar, chame t3_thread_send com
threadId <threadId do maestro>, clientRequestId aviso-<seu threadId>-<commit ou
etapa>, e uma mensagem de até 15 linhas:

Pedidos: <LJ-13 feito; LJ-14 esperando decisão>
Commit: <sha> na branch <nome> (ou onde salvou)
Arquivos: <os que você mudou>
Carrega: <nenhum | a branch ou PR de outro trabalho cujos commits estão na sua,
conferido com git merge-base --is-ancestor>
Prova: <comando> -> <resultado, quantos rodaram e quantos pulados> (ou print)
Não testado: <o quê>
Pergunta: <exata, se houver>
Recursos: worktree <caminho> (limpa ou não, commits sem push); portas <...>;
processos <PID, hora de início, comando>; containers <ID>; remotos <...>; pastas
grandes e provas que só existem aqui <...>

Depois de enviar o aviso, se terminou sem nada pendente para o dono neste chat,
chame t3_thread_organize({ action: "settle" }), sem threadId: o T3 tira o chat
dos ativos no fim do turno. Não chame se parou com uma pergunta, se falhou, ou se
espera o dono validar no localhost, aprovar um PR ou dar uma permissão aqui.
```

## Para o revisor

Troque "Como trabalhar" por: "Analise o commit <sha> da branch <nome>, sem commit
nem push. Siga <pasta do maestro>/skills/blast-radius.md e
<pasta do maestro>/skills/interrogate.md." Mantenha a "Área": é onde olhar
primeiro. No aviso, no lugar de "Prova":

```
Veredito: <pode entrar | não pode entrar>, com cada achado que bloqueia (ou
"nada bloqueia"), cada um com o comando e a saída.
Bloqueia: perder ou corromper dados, errar com dinheiro, abrir acesso ou expor
dado privado, mandar mensagem errada para fora, quebrar build, deploy ou
migração, mostrar ao usuário algo errado, faltando ou contraditório, teste
obrigatório falhando ou sem rodar.
Revisado: <commit, arquivos, testes rodados>. Sem olhar: <o quê>.
Depois: <o que não bloqueia, do mais sério ao menos>
```

### Revisor do mesmo provedor

Se o revisor for do mesmo provedor de quem construiu, com outro modelo ou com o
mesmo (`AGENTS.md`, "Revisor do mesmo provedor"), o `message` não leva o
`threadId` nem as explicações de quem construiu: só o pedido, os critérios de
aceite, a branch e o commit. Acrescente depois de "Como trabalhar":

```
## Mesma origem
Você é do mesmo provedor <ou: o mesmo modelo> de quem construiu esta mudança, e
por isso tende a achar certo o que ele achou certo. Para compensar:
- Todo achado traz um reprodutor: um teste que falha ou um script, com o comando
  exato e a saída. O que você não reproduzir vai à parte, como "não provado", e
  não conta como achado.
- Rode você mesmo os testes do projeto no commit <sha> e copie a saída. Não
  conte com a saída de quem construiu. Se rodar pedir instalação ou build, peça a
  vaga pesada pelo aviso e espere. <Com CI: rode só o rápido dos arquivos tocados
  e copie também o resultado do CI nesse commit.>
- No aviso, acrescente as linhas:
  Revisão: mesmo provedor, outro modelo <ou: mesmo modelo, chat novo>
  Testes: <comando> -> <saída>, no commit <sha>
```

## Para um lote

Pedidos novos para um chat que já existe vão numa mensagem só, com
`t3_thread_send`:

```
Lote 3 (LJ-15, LJ-16, LJ-17):
1. LJ-15: <pedido>
2. LJ-16: <pedido>
3. LJ-17: <pedido>
Responda por número e ID, no mesmo formato de aviso.
```
