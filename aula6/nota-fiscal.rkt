; nota-fiscal.rkt - total de uma nota fiscal com filter, map e foldl
; Rode com: racket nota-fiscal.rkt

#lang racket

; Cada item: (descricao quantidade preco-unitario imposto%)
(define nota
  '(("caneta"   10   2.50  10)
    ("caderno"   3  18.90  10)
    ("mochila"   0 129.00  15)    ; quantidade 0: item cancelado
    ("livro"     2  89.90   0)    ; livro: isento
    ("borracha"  5   1.20  10)))

; Acessores - so para dar nome aos car/cadr
(define (descricao item) (first item))
(define (quantidade item) (second item))
(define (preco item) (third item))
(define (imposto item) (fourth item))

; 1) filter: descarta os itens cancelados
(define itens-validos
  (filter (lambda (item) (> (quantidade item) 0)) nota))

; 2) map: transforma cada item no seu subtotal, ja com imposto
(define (subtotal item)
  (* (quantidade item) (preco item) (+ 1 (/ (imposto item) 100))))

(define subtotais (map subtotal itens-validos))

; 3) foldl: soma os subtotais
(define total (foldl + 0 subtotais))

itens-validos
subtotais
total

; Tudo numa expressao so, de dentro para fora: filter -> map -> foldl
(foldl + 0
       (map subtotal
            (filter (lambda (item) (> (quantidade item) 0)) nota)))

; Quanto foi de imposto? Mesmo esquema, outro map
(foldl + 0
       (map (lambda (item)
              (* (quantidade item) (preco item) (/ (imposto item) 100)))
            itens-validos))
