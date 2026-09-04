; =============================================================================
; exemplos-parte2.rkt - exemplos demonstrados em tutorial-racket-parte2.txt
; =============================================================================
; Carregue de um destes jeitos:
;     - DrRacket: abra o arquivo e aperte Run
;     - VS Code + Magic Racket: "Racket: Load file in REPL"
;       (veja dr-racket-or-vscode-repl.txt)
;     - terminal: racket -i -e '(enter! "exemplos-parte2.rkt")'
;
; Depois de carregado, chame as definicoes no REPL - os comentarios ";; =>"
; mostram o que esperar.
;
; Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
; exercicio esta aqui - se estivesse, os exercicios perderiam a graca.
;
; Nao ha exemplos-parte1.rkt: a parte 1 (temas 1-8) acontece inteira no REPL,
; com sexps digitadas na hora, e so encontra define no tema 12.
; =============================================================================

#lang racket

; --- Tema 9: eval ------------------------------------------------------------
; O programa e uma lista como outra qualquer; eval decide executa-la.

(define programa '(+ (* 2 3) 4))
;; programa        => '(+ (* 2 3) 4)
;; (eval programa) => 10

; --- Tema 10: apostrofo ------------------------------------------------------
; a devolve o valor guardado; 'a devolve o simbolo, sem consultar variavel.

(define a 65536)
;; a  => 65536
;; 'a => 'a

; --- Tema 11: apply ----------------------------------------------------------

(define numeros '(4 8 15 16 23 42))
;; (apply + numeros)   => 108
;; (apply max numeros) => 42

; --- Tema 12: define ---------------------------------------------------------

(define pi-aprox 3.14)

; A forma curta abaixo e syntactic sugar para
;     (define quadrado (lambda (x) (* x x)))
; As duas produzem exatamente a mesma funcao, como f1 e f2 confirmam.
(define (quadrado x) (* x x))
;; (quadrado 5) => 25

(define (media a b) (/ (+ a b) 2))
;; (media 7 10) => 17/2

(define f1 (lambda (x) (* x x)))
(define (f2 x) (* x x))
;; (equal? (f1 6) (f2 6)) => #t

; O CUIDADO do tema 12 - (define + -), que redefine o + embutido - fica de
; fora de proposito: quebraria todo o resto do arquivo. Teste no REPL, e
; feche o racket depois para restaurar os nomes originais.

; --- Tema 14: dados de apoio dos operadores logicos --------------------------

(define l '(10 100 1000))
;; (if (or (> 10 6) (= 11 12)
;;         (and (list? l) (number? (car l))))
;;     "oi"
;;     (cdr l))                  => "oi"

; --- Tema 15: cond -----------------------------------------------------------

(define (classifica n)
  (cond
    [(< n 0) "negativo"]
    [(= n 0) "zero"]
    [(< n 10) "dígito"]
    [else "grande"]))
;; (classifica -5) => "negativo"
;; (classifica  0) => "zero"
;; (classifica  7) => "dígito"
;; (classifica 42) => "grande"
