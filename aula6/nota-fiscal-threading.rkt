; nota-fiscal-threading.rkt - o mesmo calculo, escrito como pipeline com uma
;   macro ->> a la Clojure (o valor entra como ULTIMO argumento de cada forma).
; Precos em centavos: inteiros, contas exatas.
; Rode com: racket nota-fiscal-threading.rkt

#lang racket

; ->> a la Clojure: o valor entra como ULTIMO argumento de cada forma
(define-syntax ->>
  (syntax-rules ()
    [(_ x) x]
    [(_ x (f args ...) rest ...) (->> (f args ... x) rest ...)]
    [(_ x f rest ...)            (->> (f x) rest ...)]))

(define nota
  '(("caneta" 10 250 10) ("caderno" 3 1890 10) ("mochila" 0 12900 15)
    ("livro" 2 8990 0) ("borracha" 5 120 10)))
(define (quantidade item) (second item))
(define (preco item) (third item))
(define (imposto item) (fourth item))
(define (subtotal item)
  (* (quantidade item) (preco item) (+ 1 (/ (imposto item) 100))))

(->> nota
     (filter (lambda (item) (> (quantidade item) 0)))
     (map subtotal)
     (foldl + 0))

(->> nota
     (filter (lambda (item) (> (quantidade item) 0)))
     (map subtotal)
     (foldl + 0)
     (* 1/100)
     exact->inexact)
