# Forth - colinha básica

## A pilha e a notação posfixa (RPN)

Forth não tem `2 + 3`. Tem `2 3 +`: **primeiro os dados, depois o operador**.
Tudo passa por uma **pilha**: o operador consome do topo e devolve ao topo.
Não há precedência nem parênteses - a ordem em que você empilha já é a conta.

| Infixa | Posfixa | Resultado |
|---|---|---|
| 2 + 3 | `2 3 +` | 5 |
| (2 + 3) × 4 | `2 3 + 4 *` | 20 |
| 2 + (3 × 4) | `2 3 4 * +` | 14 |
| 100 / (4 + 1) | `100 4 1 + /` | 20 |
| (8 − 3) × (8 + 3) | `8 3 - 8 3 + *` | 55 |

| Palavra | Faz |
|---|---|
| `.` | tira o topo da pilha e imprime |
| `.s` | mostra a pilha inteira sem consumir: `<3> 10 20 30` (topo à **direita**) |
| `clearstack` | esvazia a pilha - use depois de um *Stack underflow* |
| `bye` | sai do interpretador |

`10 20 30 + . .` imprime `50` e depois `10`: somou os dois do topo, imprimiu,
e imprimiu o que sobrou. Pedir um valor que não existe dá **Stack underflow**.

## Aritmética com inteiros

O valor empilhado **primeiro** é o da esquerda da conta: `10 3 -` é 10 − 3.
A divisão é **inteira** (trunca): `7 2 /` dá 3, não 3.5.

| Palavra | Efeito na pilha | Exemplo | Imprime |
|---|---|---|---|
| `+` `-` `*` `/` | ( a b -- r ) | `10 3 / .` | 3 |
| `MOD` | ( a b -- resto ) | `10 3 MOD .` | 1 |
| `/MOD` | ( a b -- resto quociente ) | `10 3 /MOD . .` | 3 1 |
| `*/` | ( a b c -- a×b/c ) sem estourar o produto | `100 3 4 */ .` | 75 |
| `ABS` `NEGATE` | ( a -- \|a\| ) ( a -- −a ) | `-7 ABS .` | 7 |
| `1+` `1-` | ( a -- a+1 ) ( a -- a−1 ) | `7 1+ .` | 8 |
| `2*` `2/` | ( a -- 2a ) ( a -- a/2 ) | `7 2/ .` | 3 |
| `MIN` `MAX` | ( a b -- menor ) ( a b -- maior ) | `3 9 MAX .` | 9 |

## Manipulação da pilha

Não há variáveis para os valores intermediários: são estas palavras que
reorganizam a pilha. A notação `( antes -- depois )` lê-se com o **topo à
direita** dos dois lados.

| Palavra | Efeito | Faz | Antes | Depois |
|---|---|---|---|---|
| `DUP` | ( a -- a a ) | duplica o topo | `1 2 3` | `1 2 3 3` |
| `DROP` | ( a -- ) | joga fora o topo | `1 2 3` | `1 2` |
| `SWAP` | ( a b -- b a ) | troca os dois do topo | `1 2 3` | `1 3 2` |
| `OVER` | ( a b -- a b a ) | copia o **segundo** para o topo | `1 2 3` | `1 2 3 2` |
| `ROT` | ( a b c -- b c a ) | traz o **terceiro** para o topo | `1 2 3` | `2 3 1` |
| `NIP` | ( a b -- b ) | remove o segundo | `1 2 3` | `1 3` |
| `TUCK` | ( a b -- b a b ) | copia o topo para baixo do segundo | `1 2 3` | `1 3 2 3` |
| `2DUP` | ( a b -- a b a b ) | duplica o par do topo | `1 2` | `1 2 1 2` |
| `2DROP` | ( a b -- ) | joga fora o par do topo | `1 2 3 4` | `1 2` |
| `2SWAP` | ( a b c d -- c d a b ) | troca os dois pares | `1 2 3 4` | `3 4 1 2` |
| `DEPTH` | ( -- n ) | empilha quantos itens há | `1 2 3` | `1 2 3 3` |

`ROT` mexe só nos três do topo; do quarto para baixo nada é tocado.

### Receitas

| Objetivo | Código | Resultado |
|---|---|---|
| a² sem repetir a | `5 DUP * .` | 25 |
| a³ | `17 DUP DUP * * .` | 4913 |
| a² + b² com 3 e 4 na pilha | `3 4 DUP * SWAP DUP * + .` | 25 |
| inverter 1 2 3 em 3 2 1 | `1 2 3 SWAP ROT .s` | `<3> 3 2 1` |
| `NIP` com o que já existe | `SWAP DROP` | |
| `TUCK` com o que já existe | `SWAP OVER` | |
| `2DUP` com o que já existe | `OVER OVER` | |
| `ROT ROT` | traz o topo para o terceiro lugar | `1 2 3` → `3 1 2` |
