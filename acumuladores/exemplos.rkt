; =============================================================================
; exemplos.rkt - exemplos em Racket demonstrados em tutorial-acumuladores.txt
; =============================================================================
; Carregue de um destes jeitos:
;     - DrRacket: abra o arquivo e aperte Run
;     - VS Code + Magic Racket: "Racket: Load file in REPL"
;       (veja ../lisp/dr-racket-or-vscode-repl.txt)
;     - terminal: racket -i -e '(enter! "exemplos.rkt")'
;
; Depois de carregado, chame as funcoes no REPL - os comentarios ";; =>"
; mostram o que esperar.
;
; Cada funcao deste arquivo tem uma gemea em exemplos.sml, com o mesmo
; numero de tema. Este arquivo contem SOMENTE o que o texto demonstra:
; nenhuma resposta de exercicio esta aqui.
; =============================================================================

#lang racket

(require racket/trace)

; --- Tema 68: a recursao que trabalha na volta --------------------------------
; A mesma somar do Tema 20. As somas ficam PENDENTES ate a lista acabar.

(define (somar l)
  (if (null? l)
      0
      (+ (car l) (somar (cdr l)))))
;; (somar '(4 6 0 2)) => 12
;; (trace somar) e depois (somar '(4 6 0 2)) mostra a escada; (untrace somar)

; --- Tema 69: somar com acumulador --------------------------------------------
; A soma e feita NA IDA. O caso base so entrega o que ja esta pronto.

(define (somar-acc l acc)
  (if (null? l)
      acc
      (somar-acc (cdr l) (+ acc (car l)))))
;; (somar-acc '(4 6 0 2) 0) => 12
;; (somar-acc '() 0)        => 0
;; (somar-acc '(4 6 0 2) 100) => 112  ; o valor inicial importa

; --- Tema 70: o embrulho ------------------------------------------------------
; Quem usa nao precisa saber que existe um acumulador.

(define (somar-it l)
  (define (laço l acc)
    (if (null? l)
        acc
        (laço (cdr l) (+ acc (car l)))))
  (laço l 0))
;; (somar-it '(4 6 0 2)) => 12

; --- Tema 71: mais resultados numericos ---------------------------------------

(define (contar-elementos-acc l acc)
  (if (null? l)
      acc
      (contar-elementos-acc (cdr l) (add1 acc))))
;; (contar-elementos-acc '(5 1 4 6 10) 0) => 5

(define (contar-acc x l acc)
  (if (null? l)
      acc
      (if (equal? x (car l))
          (contar-acc x (cdr l) (add1 acc))
          (contar-acc x (cdr l) acc))))
;; (contar-acc 3 '(3 5 3 1) 0) => 2
;; (contar-acc 3 '() 0)        => 0

; --- Tema 72: resultados logicos ----------------------------------------------
; pertence? (Tema 29) ja era iterativa: a chamada recursiva e a ultima coisa.

(define (pertence? x l)
  (if (null? l)
      #f
      (if (equal? x (car l))
          #t
          (pertence? x (cdr l)))))
;; (pertence? 3 '(0 3 1 4)) => #t

; Acumulador booleano: um interruptor que vira a cada elemento.
(define (comprimento-par-acc? l acc)
  (if (null? l)
      acc
      (comprimento-par-acc? (cdr l) (not acc))))
;; (comprimento-par-acc? '(a b c d) #t) => #t
;; (comprimento-par-acc? '(a b c) #t)   => #f
;; (comprimento-par-acc? '() #t)        => #t

; Acumulador de contexto: guarda o elemento anterior, e nao um resultado.
(define (sem-vizinhos-iguais-acc? anterior l)
  (if (null? l)
      #t
      (if (equal? anterior (car l))
          #f
          (sem-vizinhos-iguais-acc? (car l) (cdr l)))))

(define (sem-vizinhos-iguais? l)
  (or (null? l)
      (sem-vizinhos-iguais-acc? (car l) (cdr l))))
;; (sem-vizinhos-iguais? '(1 2 1 2)) => #t
;; (sem-vizinhos-iguais? '(1 2 2 3)) => #f
;; (sem-vizinhos-iguais? '())        => #t

; --- Tema 73: reverse ---------------------------------------------------------
; A versao do exercicio 37.4: cada append percorre a lista inteira de novo.

(define (my-reverse l)
  (if (null? l)
      '()
      (append (my-reverse (cdr l)) (list (car l)))))
;; (my-reverse '(1 2 3 4)) => '(4 3 2 1)

; Com acumulador: cada elemento sai de uma pilha e entra na outra.
(define (reverse-acc l acc)
  (if (null? l)
      acc
      (reverse-acc (cdr l) (cons (car l) acc))))
;; (reverse-acc '(1 2 3 4) '()) => '(4 3 2 1)

(define (reverse-it l)
  (reverse-acc l '()))
;; (reverse-it '(1 2 3 4)) => '(4 3 2 1)

;; (define grande (range 20000))
;; (time (void (my-reverse grande)))  ; mais de um segundo
;; (time (void (reverse-it grande)))  ; zero milissegundos

; --- Tema 74: listas como resultado, e a ordem invertida -----------------------

(define (dobrar-acc-errado l acc)
  (if (null? l)
      acc
      (dobrar-acc-errado (cdr l) (cons (* 2 (car l)) acc))))
;; (dobrar-acc-errado '(6 7 1 -3 0) '()) => '(0 -6 2 14 12)  ; de tras para frente!

(define (dobrar-acc l acc)
  (if (null? l)
      (reverse-it acc)
      (dobrar-acc (cdr l) (cons (* 2 (car l)) acc))))
;; (dobrar-acc '(6 7 1 -3 0) '()) => '(12 14 2 -6 0)

(define (my-map-acc f l acc)
  (if (null? l)
      (reverse-it acc)
      (my-map-acc f (cdr l) (cons (f (car l)) acc))))
;; (my-map-acc add1 '(4 3 8) '()) => '(5 4 9)

(define (my-filter-acc p l acc)
  (if (null? l)
      (reverse-it acc)
      (if (p (car l))
          (my-filter-acc p (cdr l) (cons (car l) acc))
          (my-filter-acc p (cdr l) acc))))
;; (my-filter-acc even? '(2 3 4 6 7 10) '()) => '(2 4 6 10)

; --- Tema 75: quando a ordem invertida e uma vantagem --------------------------

; Contando para baixo, o acumulador ja sai na ordem certa.
(define (enumerar-acc n acc)
  (if (zero? n)
      acc
      (enumerar-acc (sub1 n) (cons n acc))))
;; (enumerar-acc 5 '()) => '(1 2 3 4 5)

; reverse-acc com um acumulador inicial que NAO e '(): juntar duas listas.
;; (reverse-acc '(3 2 1) '(4 5)) => '(1 2 3 4 5)

(define (my-append-it l1 l2)
  (reverse-acc (reverse-it l1) l2))
;; (my-append-it '(4 5) '(10 15)) => '(4 5 10 15)

; --- Tema 76: my-foldl, o esqueleto do acumulador ------------------------------
; f recebe (elemento acumulador), na mesma ordem do foldl nativo.

(define (my-foldl f acc l)
  (if (null? l)
      acc
      (my-foldl f (f (car l) acc) (cdr l))))
;; (my-foldl + 0 '(4 6 0 2))                          => 12
;; (my-foldl (lambda (x acc) (add1 acc)) 0 '(5 1 4))  => 3
;; (my-foldl cons '() '(1 2 3 4))                     => '(4 3 2 1)
;; nativo: (foldl cons '() '(1 2 3 4))                => '(4 3 2 1)

; --- Tema 77: my-foldr, o esqueleto SEM acumulador -----------------------------
; Troca cada cons por f e o '() final por inicial.

(define (my-foldr f inicial l)
  (if (null? l)
      inicial
      (f (car l) (my-foldr f inicial (cdr l)))))
;; (my-foldr + 0 '(4 6 0 2))      => 12
;; (my-foldr cons '() '(1 2 3 4)) => '(1 2 3 4)
;; (foldl - 0 '(1 2 3 4))         => 2
;; (foldr - 0 '(1 2 3 4))         => -2

; --- Tema 79: tudo e fold -----------------------------------------------------

(define (somar-f l)            (foldl + 0 l))
(define (contar-elementos-f l) (foldl (lambda (x acc) (add1 acc)) 0 l))
(define (reverse-f l)          (foldl cons '() l))
(define (my-map-f f l)         (foldr (lambda (x acc) (cons (f x) acc)) '() l))
(define (my-filter-f p l)      (foldr (lambda (x acc) (if (p x) (cons x acc) acc)) '() l))
(define (existe-f? p l)        (foldl (lambda (x acc) (or acc (p x))) #f l))
;; (somar-f '(4 6 0 2))            => 12
;; (contar-elementos-f '(3 1 4))   => 3
;; (reverse-f '(1 2 3))            => '(3 2 1)
;; (my-map-f add1 '(4 3 8))        => '(5 4 9)
;; (my-filter-f even? '(2 3 4 7))  => '(2 4)
;; (existe-f? negative? '(1 3 -1)) => #t

; Acumulador composto: soma e contagem viajando juntas, num par.
(define (media l)
  (define par (foldl (lambda (x acc) (cons (+ (car acc) x) (add1 (cdr acc))))
                     (cons 0 0)
                     l))
  (/ (car par) (cdr par)))
;; (media '(4 6 0 2)) => 3
;; (media '(1 2))     => 3/2
