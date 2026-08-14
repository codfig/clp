\ =============================================================================
\ exemplos-parte2.fs - exemplos demonstrados em tutorial-gforth-parte2.txt
\ =============================================================================
\ Carregue com:
\     gforth exemplos-parte2.fs
\ ou, ja dentro do interpretador:
\     include exemplos-parte2.fs
\
\ Este arquivo contem SOMENTE os exemplos que o texto demonstra. Nenhuma
\ resposta de exercicio esta aqui - se estivesse, os exercicios perderiam
\ a graca.
\ =============================================================================

\ --- Tema 5: definindo palavras ----------------------------------------------

: QUADRADO   ( n -- n*n )     DUP * ;
: CUBO       ( n -- n*n*n )   DUP DUP * * ;
: DOBRO      ( n -- 2n )      2 * ;
: QUADRUPLO  ( n -- 4n )      DOBRO DOBRO ;
: CELSIUS>F  ( c -- f )       9 * 5 / 32 + ;
: MEDIA2     ( a b -- media ) + 2 / ;

\ --- Tema 6: imprimindo texto ------------------------------------------------

: OLA        ( -- )   ." Ola, mundo!" CR ;
: ETIQUETA   ( n -- ) ." valor = " . CR ;

\ --- Tema 7: constantes e variaveis ------------------------------------------

100 CONSTANT MAXIMO
VARIABLE CONTADOR
0 CONTADOR !

: INCREMENTA ( -- ) 1 CONTADOR +! ;
: MOSTRA     ( -- ) ." contador = " CONTADOR @ . CR ;

\ --- Tema 8: comparacoes e condicionais --------------------------------------

: POSITIVO?  ( n -- )
   0 > IF ." positivo" ELSE ." nao positivo" THEN CR ;

: SINAL      ( n -- )
   DUP 0 > IF   ." positivo"
   ELSE DUP 0 < IF ." negativo"
   ELSE            ." zero"
   THEN THEN DROP CR ;

\ --- Tema 9: lacos contados --------------------------------------------------

: CONTAR     ( n -- ) 0 ?DO I . LOOP CR ;
: ALFABETO   ( -- )   91 65 ?DO I EMIT LOOP CR ;

: TABUADA    ( n -- )
   CR 11 1 ?DO
      DUP . ." x " I . ." = " DUP I * . CR
   LOOP DROP ;

\ --- Tema 10: lacos condicionais ---------------------------------------------

: REGRESSIVA2 ( n -- ) BEGIN DUP . 1- DUP 0= UNTIL DROP CR ;
: MDC         ( a b -- mdc ) BEGIN DUP WHILE TUCK MOD REPEAT DROP ;

\ --- Demonstracao ------------------------------------------------------------

: DEMO ( -- )
   CR ." === exemplos da parte 2 ===" CR
   ." 7 QUADRADO    = " 7 QUADRADO . CR
   ." 3 CUBO        = " 3 CUBO . CR
   ." 5 QUADRUPLO   = " 5 QUADRUPLO . CR
   ." 100 CELSIUS>F = " 100 CELSIUS>F . CR
   ." 48 18 MDC     = " 48 18 MDC . CR
   ." 7 SINAL       : " 7 SINAL
   ." 10 CONTAR     : " 10 CONTAR
   ." ALFABETO      : " ALFABETO
   ." 5 REGRESSIVA2 : " 5 REGRESSIVA2
   OLA ;

CR .( exemplos-parte2.fs carregado. Digite  DEMO  para ver tudo rodando. ) CR
