# Recursão sobre listas - colinha básica

## O esqueleto (é sempre o mesmo)

Toda função recursiva sobre uma lista tem três ingredientes: a lista é um
parâmetro; o **primeiro teste** é `(null? l)`; no caso geral aparecem a cabeça
`(car l)` e uma chamada recursiva sobre a cauda `(cdr l)`.

```racket
(define (f l)
  (if (null? l)
      <caso base>                ; para '()
      (<op> (car l) (f (cdr l)))))  ; cabeça + resto
```

Sem o teste `(null? l)` a recursão não para: chega em `(cdr '())` e quebra.

## O pulo do gato

A máquina **não vê a lista inteira** - só a cabeça. O resto é um borrão:

```
Humano:   '(4 0 -2 3 9 6 20 -4 7)
Máquina:  '(4 <bla bla bla...>)
```

Não tente enxergar através do borrão nem simular todas as chamadas. Há só
**dois tijolinhos** na mesa:

| Tijolinho | O que é |
|---|---|
| `(car l)` | a cabeça - o que você vê de verdade |
| `(f (cdr l))` | o resto **já resolvido, por mágica**: trate como um dado pronto |

Sua única tarefa é escolher o **operador** que combina os dois. Como a
recursão chegou ao resultado da cauda não é problema seu.

## A tabela: o tipo do retorno decide o resto

O caso base é o **elemento neutro** do operador do caso geral.

| Tipo de retorno | Caso base | Operador do caso geral |
|---|---|---|
| número | `0`, `1`, ... | `+`, `add1`, `*`, ... |
| lista | `'()` | `cons` |
| booleano | `#f` ("existe algum?") / `#t` ("todos?") | `or` / `and`, `not` |

Numa lista vazia não existe nenhum (`#f`) e todos satisfazem, por vacuidade
(`#t`).

## Quatro funções, uma por tipo

```racket
; número: somar os elementos
;   (somar '(4 6 0 2)) → 12
(define (somar l)
  (if (null? l)
      0
      (+ (car l) (somar (cdr l)))))

; lista: o dobro de cada elemento
;   (dobrar '(6 7 -3)) → '(12 14 -6)
(define (dobrar l)
  (if (null? l)
      '()
      (cons (* 2 (car l)) (dobrar (cdr l)))))

; booleano: x está na lista?
;   (pertence? 3 '(0 3 1)) → #t
(define (pertence? x l)
  (if (null? l)
      #f
      (if (equal? x (car l))
          #t
          (pertence? x (cdr l)))))

; função como parâmetro: só os que passam no teste
;   (my-filter even? '(2 3 4 6 7)) → '(2 4 6)
(define (my-filter p l)
  (if (null? l)
      '()
      (if (p (car l))
          (cons (car l) (my-filter p (cdr l)))
          (my-filter p (cdr l)))))
```

Use `cons`, não `list`, no caso geral: `(list x (dobrar (cdr l)))` cria uma
lista de dois elementos com a cauda inteira aninhada dentro.

## Para reconhecer um problema novo

| Pergunta | Opções |
|---|---|
| Qual o tipo do retorno? | número, lista, booleano → tabela acima |
| Quantas vezes a cabeça entra no resultado? | uma (`dobrar`), zero ou uma conforme teste (`my-filter`), duas |
| Quanto a recursão anda? | um elemento (comum), dois, um em cada lista |
| Quantos casos base? | um (`'()`) ou dois (lista unitária, segunda lista, contador) |
| A operação é fixa ou parâmetro? | fixa: `dobrar`, `pertence?` - parâmetro: `my-map`, `existe?`, `my-filter` |

| Escrita à mão | Generalizada | Nativa em Racket | Faz |
|---|---|---|---|
| `dobrar` | `my-map` | `map` | transforma cada elemento |
| `pertence?` | `existe?` | `ormap` | pergunta "algum?" |
| - | `todos?` | `andmap` | pergunta "todos?" |
| `remove-todos` | `my-filter` | `filter` | seleciona alguns |
