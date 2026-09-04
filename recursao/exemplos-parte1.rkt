; =============================================================================
; exemplos-parte1.rkt - exemplos demonstrados em tutorial-recursao-parte1.txt
; =============================================================================
; Carregue de um destes jeitos:
;     - DrRacket: abra o arquivo e aperte Run
;     - VS Code + Magic Racket: "Racket: Load file in REPL"
;       (veja ../lisp/dr-racket-or-vscode-repl.txt)
;     - terminal: racket -i -e '(enter! "exemplos-parte1.rkt")'
;
; Depois de carregado, chame as funcoes no REPL - os comentarios ";; =>"
; mostram o que esperar.
;
; Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
; exercicio esta aqui - contar-elementos (tema 22), produto (23.2),
; quadrados (25.1) e remove-todos (26.2) sao seus, nao meus.
;
; Para digitar suas proprias solucoes, use um arquivo separado - funcoes.rkt,
; por exemplo, como sugere dr-racket-or-vscode-repl.txt.
; =============================================================================

#lang racket

; --- Tema 16: relembrando define ---------------------------------------------

(define (quadrado x) (* x x))
;; (quadrado 5) => 25

(define (media a b) (/ (+ a b) 2))
;; (media 7 10) => 17/2

; --- Tema 20: somar ----------------------------------------------------------
; Retorno numerico: caso base 0 (neutro da soma), operador + no caso geral.

(define (somar l)
  (if (null? l)
      0
      (+ (car l) (somar (cdr l)))))
;; (somar '(4 6 0 2)) => 12
;; (somar '())        => 0

; --- Tema 21: contar ---------------------------------------------------------
; equal?, e nao =, para funcionar tambem com simbolos e strings.

(define (contar x l)
  (if (null? l)
      0
      (if (equal? x (car l))
          (add1 (contar x (cdr l)))
          (contar x (cdr l)))))
;; (contar 3 '(3 5 3 1)) => 2
;; (contar 3 '(4 6 0 2)) => 0

; --- Tema 24: dobrar ---------------------------------------------------------
; Retorno em lista: caso base '(), operador cons no caso geral.

(define (dobrar l)
  (if (null? l)
      '()
      (cons (* 2 (car l)) (dobrar (cdr l)))))
;; (dobrar '(6 7 1 -3 0)) => '(12 14 2 -6 0)
;; (dobrar '())           => '()

; --- Tema 26: remove-primeiro ------------------------------------------------
; Achar o valor ENCERRA a busca: (cdr l) vai direto, sem chamada recursiva.

(define (remove-primeiro v l)
  (if (null? l)
      '()
      (if (equal? v (car l))
          (cdr l)
          (cons (car l) (remove-primeiro v (cdr l))))))
;; (remove-primeiro 3 '(4 3 8 10 3 5)) => '(4 8 10 3 5)
;; (remove-primeiro 7 '(4 3 8))        => '(4 3 8)

; --- Tema 27: lambda ---------------------------------------------------------
; As duas formas produzem a mesma funcao - a curta e syntactic sugar da longa.

(define f1 (lambda (x) (* x x)))
(define (f2 x) (* x x))
;; (equal? (f1 6) (f2 6)) => #t
;; ((lambda (x) (+ x 10)) 5) => 15

; --- Tema 28: my-map ---------------------------------------------------------
; dobrar com a operacao virando parametro: a primeira funcao de ordem superior.

(define (my-map f l)
  (if (null? l)
      '()
      (cons (f (car l)) (my-map f (cdr l)))))
;; (my-map add1 '(4 3 8))                   => '(5 4 9)
;; (my-map (lambda (x) (* x x)) '(1 2 3))   => '(1 4 9)
;; (my-map (lambda (x) (* 2 x)) '(6 7 1))   => o mesmo que (dobrar '(6 7 1))
;; (equal? (my-map add1 '(1 2 3)) (map add1 '(1 2 3))) => #t
