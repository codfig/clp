# Regex - colinha básica

Uma expressão regular (regex) é um **padrão** que descreve um conjunto de
textos. Duas regras valem para tudo abaixo:

1. Sem âncoras, o padrão casa em **qualquer posição** do texto - e pode
   casar várias vezes. `[0-9]{3}` em `2026` casa «202».
2. Todo caractere casa **ele mesmo**, exceto os metacaracteres
   `. [ ] ^ $ * + ? { } ( ) | \` - para casar um deles ao pé da letra,
   ponha `\` na frente: `\.` `\$` `\(` `\\`.

## Caracteres

| Símbolo | Significa | Exemplo | Casa |
|---|---|---|---|
| `.` | um caractere qualquer | `a.c` | abc, a-c, a c |
| `\.` | um ponto literal | `a\.c` | a.c |
| `[abc]` | um caractere do conjunto | `[gr]ato` | gato, rato |
| `[a-z]` | um caractere do intervalo | `[a-z][0-9]` | b2 |
| `[a-zA-Z0-9]` | intervalos convivem na mesma classe | `[A-Z0-9]` | Q, 7 |
| `[^abc]` | um caractere FORA do conjunto | `[^0-9]` | a, %, espaço |
| `\d` `\w` `\s` | atalhos: dígito, letra/dígito/`_`, espaço | `\d\d` | 42 |

Dentro de `[ ]` os metacaracteres perdem o poder: `[.]` é um ponto literal.
O hífen vai no fim (`[0-9-]`) e o `^` só nega se for o primeiro.

## Âncoras

Não casam caracteres, casam **posições**.

| Símbolo | Significa | Exemplo | Casa | Não casa |
|---|---|---|---|---|
| `^` | início do texto | `^casa` | casarão | descasar |
| `$` | fim do texto | `fim$` | o fim | fim da linha |
| `^...$` | o texto é exatamente isto | `^cat$` | cat | cats, gato |
| `\b` | fronteira de palavra | `\bcat\b` | cat | concatenar |

## Quantificadores

Aplicam-se ao item **imediatamente anterior**: um caractere, uma classe
`[ ]` ou um grupo `( )`. `ab+` é um `a` e vários `b`; `(ab)+` é `ab` repetido.

| Símbolo | Repetições | Exemplo | Casa | Não casa |
|---|---|---|---|---|
| `*` | zero ou mais | `ba*nana` | bnana, banana, baaanana | bxnana |
| `+` | uma ou mais | `ba+nana` | banana, baaanana | bnana |
| `?` | zero ou uma (opcional) | `casas?` | casa, casas | casinha |
| `{n}` | exatamente n | `[0-9]{3}` | 123 | 12 |
| `{n,m}` | de n a m | `a{2,4}` | aa, aaa, aaaa | a |
| `{n,}` | n ou mais | `[0-9]{2,}` | 12, 12345 | 1 |

`*` e `+` são **gulosos**: pegam o maior trecho possível. `*` e `?` também
casam **zero** vezes - `[0-9]*` é satisfeito por um texto sem dígito nenhum.

## Alternância e grupos

| Símbolo | Significa | Exemplo | Casa | Não casa |
|---|---|---|---|---|
| `\|` | ou | `gato\|rato` | gato, rato | pato |
| `( )` | grupo | `(g\|r)ato` | gato, rato | pato |
| `( )+` | grupo repetido | `(ab)+` | ab, abab | abb |

O `\|` tem a **menor** precedência: sem parênteses, divide a expressão inteira.

| Regex | Lê-se |
|---|---|
| `^a\|b$` | começa com `a` **ou** termina com `b` |
| `^(a\|b)$` | o texto é exatamente `a` ou `b` |

## Exemplos num texto maior

«...» marca o trecho casado.

| Texto | |
|---|---|
| A | `O gato preto subiu no telhado as 07:45 de 12/03/2026.` |
| B | `preco: R$ 1.299,90 -- codigo AB-12345, tel (11) 98765-4321` |
| C | `disse "oi" e depois "tchau" para todos` |

| Regex | Casa |
|---|---|
| `.ato` | O «gato» preto subiu... |
| `pret[oa]s?` | O gato «preto» subiu... |
| `sub[a-z]*` | ...preto «subiu» no telhado... |
| `gato\|telhado` | O «gato» preto subiu no «telhado» as... |
| `[0-9]+` | ...as «07»:«45» de «12»/«03»/«2026». |
| `[0-9]+:[0-9]+` | ...as «07:45» de... |
| `[0-9]{2}/[0-9]{2}/[0-9]{4}` | ...de «12/03/2026». |
| `[A-Z]{2}-[0-9]{5}` | ...codigo «AB-12345», tel... |
| `R\$ [0-9.]+,[0-9]{2}` | preco: «R$ 1.299,90» -- codigo... |
| `\([0-9]{2}\) [0-9]{4,5}-[0-9]{4}` | ...tel «(11) 98765-4321» |
| `".*"` | disse «"oi" e depois "tchau"» para todos |
| `"[^"]*"` | disse «"oi"» e depois «"tchau"» para todos |

Os dois últimos são a mesma pergunta - "um trecho entre aspas" - com o `.*`
guloso engolindo tudo até a última aspa, e `[^"]*` parando na primeira.
