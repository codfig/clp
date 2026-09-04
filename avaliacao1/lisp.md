# Lisp / Racket - colinha básica

## Sintaxe: só existe a s-expression

Uma sexp é um **átomo** (`42`, `3.14`, `"olá"`, `soma`) ou uma **lista** de sexps
entre parênteses. Uma chamada é uma lista cujo **primeiro** elemento é a
função: notação **prefixa**, sem vírgulas, sem precedência - o aninhamento dá
a ordem. Todo parêntese aberto tem que fechar.

| Expressão | Resultado | |
|---|---|---|
| `(+ 2 3)` | `5` | |
| `(* 2 3 4)` | `24` | dois ou mais argumentos |
| `(+ 2 (* 3 4))` | `14` | o mais interno primeiro |
| `(- 5)` | `-5` | |
| `(/ 10 3)` | `10/3` | fração **exata**, não trunca |
| `(/ 10.0 3)` | `3.3333333333333335` | |
| `(quotient 10 3)` `(remainder 10 3)` | `3` `1` | divisão inteira e resto |
| `(expt 2 10)` `(sqrt 16)` | `1024` `4` | |
| `(max 3 9)` `(min 3 9)` | `9` `3` | |

## Pares e listas

Tudo é feito de **células cons**: um par `[car | cdr]`. Uma lista é uma cadeia
de cons que termina em `'()`, a lista vazia.

| Expressão | Resultado | |
|---|---|---|
| `(cons 4 5)` | `'(4 . 5)` | par; o ponto = não é lista |
| `(car (cons 4 5))` `(cdr (cons 4 5))` | `4` `5` | |
| `(cons 10 (cons 100 '()))` | `'(10 100)` | `[10\|*]->[100\|*]->'()` |
| `'(10 100 1000)` `(list 10 100 1000)` | `'(10 100 1000)` | mesma lista; `list` avalia os argumentos |
| `(car '(10 100 1000))` | `10` | a cabeça |
| `(cdr '(10 100 1000))` | `'(100 1000)` | o resto - sempre uma lista |
| `(cons 1 '(2 3))` | `'(1 2 3)` | põe na frente |
| `(cons 1 (cons 2 3))` | `'(1 2 . 3)` | não termina em `'()`: **não** é lista |
| `(null? '())` `(null? '(1))` | `#t` `#f` | |
| `(list? '())` `(pair? '())` | `#t` `#f` | |
| `(pair? (cons 4 5))` `(list? (cons 4 5))` | `#t` `#f` | |

## quote, eval, apply

Toda lista é candidata a programa (homoiconicidade). `'x` é açúcar para
`(quote x)`: **desliga** a avaliação e devolve a sexp como dado. `eval` faz o
caminho inverso. `apply` chama uma função com os argumentos vindos numa lista.

| Expressão | Resultado |
|---|---|
| `(+ 2 3)` | `5` |
| `'(+ 2 3)` | `'(+ 2 3)` |
| `(eval '(+ 2 3))` | `5` |
| `(apply + '(1 2 3 4))` | `10` - o mesmo que `(+ 1 2 3 4)` |
| `(apply max '(3 7 2 9 1))` | `9` |

## define

`(define nome valor)` para variável; `(define (nome parâmetros) corpo)` para
função. O corpo é **uma expressão**, cujo valor é o retorno.

```racket
(define (maior a b)        ; nome: maior   parâmetros: a b
  (if (> a b)              ; teste
      a                    ; então
      b))                  ; senão

(maior 7 10)               ; 10
```

É açúcar para `(define maior (lambda (a b) (if (> a b) a b)))`: uma função é um
valor como outro qualquer, produzido por `lambda`.

## Condicionais, comparações, lógicos

`if` é uma **expressão** (produz valor) com três partes obrigatórias:
`(if teste então senão)`. O **único** valor falso é `#f` - `0`, `""` e `'()`
contam como verdadeiro.

| Expressão | Resultado |
|---|---|
| `(if (> 3 10) (+ 4 10) (- 4 10))` | `-6` |
| `(if 0 "v" "f")` `(if '() "v" "f")` | `"v"` `"v"` |
| `(= 3 3)` `(< 3 10)` `(>= 10 3)` | `#t` - só para **números** |
| `(equal? '(1 2 3) '(1 2 3))` `(equal? "oi" "oi")` | `#t` - compara qualquer coisa |
| `(and (> 10 6) (= 2 2))` `(or (> 3 10) (= 5 5))` `(not (> 3 10))` | `#t` `#t` `#t` |
| `(and 1 2 3)` `(or #f #f 5)` | `3` `5` - devolvem o **valor**, não só `#t` |
| `(number? 3)` `(symbol? 'a)` `(string? "x")` `(list? '(1))` | `#t` - predicados de tipo |

`cond` encadeia vários testes; `else` fecha:

```racket
(cond
  [(< n 0) "negativo"]
  [(= n 0) "zero"]
  [else    "positivo"])
```
