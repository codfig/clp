; =============================================================================
; exemplos-parte2.rkt - exemplos demonstrados em tutorial-recursao-parte2.txt
; =============================================================================
; Carregue de um destes jeitos:
;     - DrRacket: abra o arquivo e aperte Run
;     - VS Code + Magic Racket: "Racket: Load file in REPL"
;       (veja ../lisp/dr-racket-or-vscode-repl.txt)
;     - terminal: racket -i -e '(enter! "exemplos-parte2.rkt")'
;
; Depois de carregado, chame as funcoes no REPL - os comentarios ";; =>"
; mostram o que esperar.
;
; Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
; exercicio esta aqui: nenhum?, my-ormap, my-andmap, my-remove-duplicates,
; my-partition, substituir, intercalar, my-reverse, misturar, my-map2,
; impares, pares, ordenado?, segue, my-drop, achatar e ordenar sao seus.
;
; remove-primeiro (tema 26) e my-map (tema 28) estao em exemplos-parte1.rkt.
; =============================================================================

#lang racket

; --- Tema 29: pertence? ------------------------------------------------------
; Retorno booleano: caso base #f, e a resposta da recursao vai direto.

(define (pertence? x l)
  (if (null? l)
      #f
      (if (equal? x (car l))
          #t
          (pertence? x (cdr l)))))
;; (pertence? 3 '(0 3 1 4)) => #t
;; (pertence? 3 '(5 1 4))   => #f
;; (pertence? 3 '())        => #f

; --- Tema 31: a mesma funcao como expressao logica ---------------------------
; O texto chama as duas de pertence?; num mesmo arquivo os nomes precisam
; diferir, entao a versao declarativa fica como pertence-decl?.
; O (and (not (null? l)) ...) e o caso base disfarcado de operador logico:
; devolve #f para a lista vazia e protege o car e o cdr que vem depois.

(define (pertence-decl? x l)
  (and (not (null? l))
       (or (equal? x (car l))
           (pertence-decl? x (cdr l)))))
;; (pertence-decl? 3 '(0 3 1 4)) => #t
;; (equal? (pertence? 3 '(5 1 4)) (pertence-decl? 3 '(5 1 4))) => #t
;; curto-circuito: (or #t (car '())) => #t ; (and #f (car '())) => #f

; --- Tema 32: existe? --------------------------------------------------------
; pertence? com o teste virando parametro: p e um PREDICADO, aplicado
; como (p (car l)) - nunca (p l) nem (p car l).

(define (existe? p l)
  (if (null? l)
      #f
      (if (p (car l))
          #t
          (existe? p (cdr l)))))
;; (existe? even? '(1 3 7 -1))                          => #f
;; (existe? negative? '(1 3 7 -1))                      => #t
;; (existe? (lambda (x) (= 0 (modulo x 2))) '(1 3 11))  => #f
;; (existe? (lambda (x) (= 0 (modulo x 2))) '(1 2))     => #t
;; (existe? number? '("oi" ()))                         => #f
;; (existe? boolean? '(4 (5 6) #t 5))                   => #t
;; equivale ao ormap nativo: (ormap even? '(1 2 3))     => #t

(define (existe-decl? p l)
  (and (not (null? l))
       (or (p (car l))
           (existe-decl? p (cdr l)))))
;; (existe-decl? even? '(1 2)) => #t

; --- Tema 33: todos? ---------------------------------------------------------
; O dual de existe?: trocam-se #f por #t e or por and, e nada mais.
; Caso base #t por vacuidade - lista vazia nao tem contraexemplo.

(define (todos? p l)
  (if (null? l)
      #t
      (and (p (car l))
           (todos? p (cdr l)))))
;; (todos? pair? '((9 12 20) (3 3) (4 0 0 11))) => #t
;; (todos? number? '(4 5 6 #f))                 => #f
;; (todos? positive? '(1 2 3))                  => #t
;; (todos? number? '())                         => #t
;; equivale ao andmap nativo: (andmap positive? '(1 2 3)) => #t

; --- Tema 34: remove-todos ---------------------------------------------------
; Ao contrario de remove-primeiro (exemplos-parte1.rkt), achar o valor nao
; encerra nada: a recursao continua nos dois ramos, e o cons e que some.

(define (remove-todos v l)
  (if (null? l)
      '()
      (if (equal? v (car l))
          (remove-todos v (cdr l))
          (cons (car l) (remove-todos v (cdr l))))))
;; (remove-todos 3 '(4 3 8 10 3 5 5 3 2)) => '(4 8 10 5 5 2)
;; (remove-todos 7 '(4 3 8))              => '(4 3 8)
;; (remove-todos 3 '(3 3 3))              => '()

; --- Tema 35: my-filter ------------------------------------------------------
; remove-todos com o teste virando parametro - os dois ramos do if trocados
; de lugar, porque agora o teste manda GUARDAR, e nao descartar.

(define (my-filter p l)
  (if (null? l)
      '()
      (if (p (car l))
          (cons (car l) (my-filter p (cdr l)))
          (my-filter p (cdr l)))))
;; (my-filter even? '(2 3 4 6 7 10))          => '(2 4 6 10)
;; (my-filter number? '(1 "oi" 2 #t))         => '(1 2)
;; (my-filter (lambda (x) (> x 5)) '(3 9 1 8)) => '(9 8)
;; equivale ao filter nativo: (filter even? '(2 3 4)) => '(2 4)

; --- Tema 36: gaguinho -------------------------------------------------------
; A cabeca entra DUAS vezes, e cada cons encaixa um elemento: dois cons
; aninhados. (list (car l) (car l)) daria uma lista de pares, nao uma lista.

(define (gaguinho l)
  (if (null? l)
      '()
      (cons (car l)
            (cons (car l)
                  (gaguinho (cdr l))))))
;; (gaguinho '(3 7 8 b)) => '(3 3 7 7 8 8 b b)
;; (gaguinho '())        => '()

; --- Tema 37: my-append ------------------------------------------------------
; Duas listas, recursao em uma so. O caso base NAO e '(): com l1 esgotada,
; a resposta certa e l2 inteira.

(define (my-append l1 l2)
  (if (null? l1)
      l2
      (cons (car l1) (my-append (cdr l1) l2))))
;; (my-append '(4 5) '(10 15))  => '(4 5 10 15)
;; (my-append '() '(10 10 5))   => '(10 10 5)
;; (my-append l-um l-dois)      => '(3 1 2 3 10 3 1 3)

; --- Tema 38: ziper ----------------------------------------------------------
; Duas listas consumidas ao mesmo tempo: dois casos base, dois cdr por
; chamada, e dois cons cuja ORDEM importa.

(define (zíper l1 l2)
  (cond [(null? l1) l2]
        [(null? l2) l1]
        [else (cons (car l1)
                    (cons (car l2)
                          (zíper (cdr l1) (cdr l2))))]))
;; (zíper '(a 3 z) '(9 c b))    => '(a 9 3 c z b)
;; (zíper '(1 10) '(-1 0 -2 7)) => '(1 -1 10 0 -2 7)
;; (zíper '() '(1 2))           => '(1 2)

; --- Tema 39: alternar -------------------------------------------------------
; Olha o segundo elemento, anda de dois em dois, e por isso precisa do caso
; base da lista unitaria - sem ele, so as listas de tamanho impar quebram.

(define (alternar l)
  (cond [(null? l) '()]
        [(null? (cdr l)) l]
        [else (cons (car (cdr l))
                    (cons (car l)
                          (alternar (cdr (cdr l)))))]))
;; (alternar '(3 9 1 8 0)) => '(9 3 8 1 0)
;; (alternar l-um)         => '(1 3 3 2)
;; (alternar '(7))         => '(7)

; --- Tema 40: my-take --------------------------------------------------------
; Encolhem DOIS parametros por chamada: a lista, com cdr, e o contador, com
; sub1. Dois casos base, com a mesma resposta, testados juntos com or.

(define (my-take n l)
  (if (or (zero? n) (null? l))
      '()
      (cons (car l) (my-take (sub1 n) (cdr l)))))
;; (my-take 3 '(1 0 12 15 8)) => '(1 0 12)
;; (my-take 9 '(1 2))         => '(1 2)
;; (my-take 0 '(1 2))         => '()
;; o take nativo inverte a ordem dos argumentos: (take '(1 2 3) 2) => '(1 2)

; --- Listas de apoio, como no material original ------------------------------

(define l-um '(3 1 2 3))
(define l-dois '(10 3 1 3))
;; (gaguinho l-um)            => '(3 3 1 1 2 2 3 3)
;; (my-append (cdr l-um) l-dois) => '(1 2 3 10 3 1 3)
