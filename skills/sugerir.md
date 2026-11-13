# Sugerir ao maestro

Use quando o dono disser "sugira ao maestro: ...", ou o equivalente no idioma
dele (em inglês, "suggest to maestro: ..."), ou quando o `reflect` achar algo que
serve a todos e não só a esta cópia. A sugestão vai para quem mantém a base; nada
sai da máquina sem o ok do dono.

## Redigir

Escreva em `local/sugestoes/<aaaa-mm-dd>-<tema>.md`, no idioma do dono, para ele
entender tudo o que vai sair da máquina:

- **Problema:** o que deu errado ou faltou, em duas ou três frases.
- **Exemplo:** um caso fictício que mostre o problema. Nunca o estado, as pautas,
  a conversa, nomes de pessoas, de projetos, de máquinas ou caminhos reais.
- **Onde mudar:** o arquivo da base e a seção.
- **Proposta:** o texto novo, curto.
- **Versão:** a de `VERSION`.

## Conferir

1. Rode `scripts/checar-privacidade.sh --arquivo local/sugestoes/<arquivo>`. Ele
   procura caminhos de máquina, IDs de chat, e-mails, credenciais, os termos da
   base e os termos privados desta cópia: o nome do dono no config e cada linha
   de `local/termos-privados.txt`, se existir.
2. Se acusar algo, reescreva e rode de novo.
3. Mostre o texto final ao dono, inteiro.

## Enviar

Só depois do ok dele: `gh issue create --repo <dono/repositório da origem> --title
"<título>" --body-file local/sugestoes/<arquivo>`. Sem `gh` ou sem conta, entregue o
texto para ele encaminhar. Anote o link da issue na pauta `casa`.
