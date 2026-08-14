\ =============================================================================
\ exemplos.fs - biblioteca de exemplos do tutorial de gforth (aula1)
\ =============================================================================
\ Carregue este arquivo dentro do gforth com:
\     include exemplos.fs
\ ou direto da linha de comando:
\     gforth exemplos.fs
\
\ Comentarios em Forth:
\   \  (contrabarra + espaco)  comenta ate o fim da linha
\   (  texto )                 comenta ate o parentese de fechamento
\ A convencao ( antes -- depois ) documenta o efeito na pilha.
\ =============================================================================

\ -----------------------------------------------------------------------------
\ 1. ARITMETICA E PALAVRAS SIMPLES
\ -----------------------------------------------------------------------------

: QUADRADO   ( n -- n*n )        DUP * ;
: CUBO       ( n -- n*n*n )      DUP DUP * * ;
: DOBRO      ( n -- 2n )         2 * ;
: MEDIA2     ( a b -- media )    + 2 / ;
: PERCENTUAL ( parte total -- % ) SWAP 100 * SWAP / ;
: CELSIUS>F  ( c -- f )          9 * 5 / 32 + ;
: F>CELSIUS  ( f -- c )          32 - 5 * 9 / ;

\ -----------------------------------------------------------------------------
\ 2. CONSTANTES E VARIAVEIS
\ -----------------------------------------------------------------------------

100      CONSTANT MAXIMO
3        CONSTANT PI-INTEIRO       \ Forth classico trabalha com inteiros
VARIABLE CONTADOR
VARIABLE ACUMULADOR
0 CONTADOR !
0 ACUMULADOR !

: ZERAR      ( -- )    0 CONTADOR ! 0 ACUMULADOR ! ;
: INCREMENTA ( -- )    1 CONTADOR +! ;
: SOMA-NELE  ( n -- )  ACUMULADOR +! ;
: MOSTRA     ( -- )    ." contador=" CONTADOR @ . ." acumulador=" ACUMULADOR @ . CR ;

\ -----------------------------------------------------------------------------
\ 3. SAIDA DE TEXTO
\ -----------------------------------------------------------------------------

: OLA        ( -- )    ." Ola, mundo!" CR ;
: SAUDACAO   ( -- )    CR ." === Tutorial de Forth - aula1 ===" CR ;
: LINHA      ( -- )    60 0 ?DO [CHAR] - EMIT LOOP CR ;
: TITULO     ( -- )    LINHA ."   gforth no Windows  " CR LINHA ;

\ -----------------------------------------------------------------------------
\ 4. CONDICIONAIS
\ -----------------------------------------------------------------------------

: SINAL   ( n -- )
   DUP 0 > IF   ." positivo"
   ELSE DUP 0 < IF ." negativo"
   ELSE            ." zero"
   THEN THEN DROP CR ;

: PAR?    ( n -- flag )  2 MOD 0= ;
: PAR-IMPAR ( n -- )     PAR? IF ." par" ELSE ." impar" THEN CR ;

: MAIOR   ( a b -- max ) 2DUP < IF SWAP THEN DROP ;
: MENOR   ( a b -- min ) 2DUP > IF SWAP THEN DROP ;

: NOTA    ( n -- )
   DUP 90 >= IF ." A"  ELSE
   DUP 80 >= IF ." B"  ELSE
   DUP 70 >= IF ." C"  ELSE
   DUP 60 >= IF ." D"  ELSE
                 ." F"
   THEN THEN THEN THEN DROP CR ;

\ -----------------------------------------------------------------------------
\ 5. LACOS CONTADOS (DO ... LOOP)
\ -----------------------------------------------------------------------------

\ ATENCAO: prefira ?DO a DO. Com DO, se limite = indice inicial o laco roda
\ 2^64 vezes (ele so testa no fim); ?DO testa antes e nao executa nenhuma vez.
: CONTAR    ( n -- )      0 ?DO I . LOOP CR ;       \ 0 1 2 ... n-1
: DE-ATE    ( ini fim -- ) SWAP ?DO I . LOOP CR ;
: PARES-ATE ( n -- )      0 ?DO I . 2 +LOOP CR ;    \ +LOOP com passo 2
: REGRESSIVA ( n -- )     0 SWAP ?DO I . -1 +LOOP CR ;   \ passo negativo

: TABUADA   ( n -- )
   CR 11 1 DO
      DUP . ." x " I . ." = " DUP I * . CR
   LOOP DROP ;

: SOMA-ATE  ( n -- soma )  0 SWAP 1+ 1 ?DO I + LOOP ;
: FATORIAL  ( n -- n! )    1 SWAP 1+ 1 ?DO I * LOOP ;

: MATRIZ    ( -- )         \ laco aninhado: I = interno, J = externo
   4 1 ?DO
      4 1 ?DO  I J * 4 .R  LOOP  CR
   LOOP ;

\ -----------------------------------------------------------------------------
\ 6. LACOS CONDICIONAIS (BEGIN ... UNTIL / WHILE ... REPEAT)
\ -----------------------------------------------------------------------------

: REGRESSIVA2 ( n -- )
   BEGIN DUP . 1- DUP 0= UNTIL DROP CR ;

: DOBRA-ATE ( n limite -- resultado )
   SWAP BEGIN 2DUP > WHILE 2 * REPEAT NIP ;

: DIGITOS   ( n -- qtd )    \ quantos digitos tem o numero
   0 SWAP BEGIN 10 / SWAP 1+ SWAP DUP 0= UNTIL DROP ;

\ -----------------------------------------------------------------------------
\ 7. RECURSAO
\ -----------------------------------------------------------------------------

: FAT-REC ( n -- n! )
   DUP 1 <= IF DROP 1 ELSE DUP 1- RECURSE * THEN ;

: FIB ( n -- fib )
   DUP 2 < IF EXIT THEN
   DUP 1- RECURSE SWAP 2 - RECURSE + ;

: MDC ( a b -- mdc )        \ algoritmo de Euclides
   BEGIN DUP WHILE TUCK MOD REPEAT DROP ;

\ -----------------------------------------------------------------------------
\ 8. MEMORIA E VETORES
\ -----------------------------------------------------------------------------

CREATE VETOR 10 CELLS ALLOT      \ reserva espaco para 10 celulas

: VETOR[]   ( i -- addr )   CELLS VETOR + ;          \ endereco do item i
: V!        ( n i -- )      VETOR[] ! ;              \ grava
: V@        ( i -- n )      VETOR[] @ ;              \ le
: PREENCHE  ( -- )          10 0 ?DO I QUADRADO I V! LOOP ;
: MOSTRA-VETOR ( -- )       10 0 ?DO I V@ 5 .R LOOP CR ;
: SOMA-VETOR   ( -- soma )  0 10 0 ?DO I V@ + LOOP ;

CREATE PRIMOS  2 , 3 , 5 , 7 , 11 , 13 , 17 , 19 , 23 , 29 ,   \ tabela literal
: PRIMO@    ( i -- n )      CELLS PRIMOS + @ ;
: LISTA-PRIMOS ( -- )       10 0 ?DO I PRIMO@ . LOOP CR ;

\ -----------------------------------------------------------------------------
\ 9. STRINGS
\ -----------------------------------------------------------------------------

: DIGA     ( c-addr u -- )  ." [" TYPE ." ]" CR ;
: GRITA    ( -- )           S" forth e divertido" DIGA ;
: ALFABETO ( -- )           [CHAR] A [CHAR] Z 1+ SWAP ?DO I EMIT LOOP CR ;
: REPETE   ( c n -- )       0 ?DO DUP EMIT LOOP DROP CR ;

\ -----------------------------------------------------------------------------
\ 10. PONTO FLUTUANTE (pilha de floats, separada da pilha de inteiros)
\ -----------------------------------------------------------------------------
\ Numeros float precisam do expoente: 3.14e0  ou  3.14e
\ Palavras de float comecam com F: F+ F- F* F/ F. FSQRT FDUP

: AREA-CIRCULO ( F: r -- area )  FDUP F* 3.14159265e F* ;
: HIPOTENUSA   ( F: a b -- c )   FDUP F* FSWAP FDUP F* F+ FSQRT ;
: MOSTRA-AREA  ( F: r -- )       AREA-CIRCULO ." area = " F. CR ;

\ -----------------------------------------------------------------------------
\ 11. CREATE ... DOES>  (o superpoder do Forth: criar novas "classes" de palavras)
\ -----------------------------------------------------------------------------

: CONSTANTE-NOMEADA ( n "nome" -- )   CREATE , DOES> @ ;
\ uso:  42 CONSTANTE-NOMEADA RESPOSTA    ->  RESPOSTA . mostra 42

: VETOR-DE ( n "nome" -- )            \ cria um vetor de n celulas
   CREATE CELLS ALLOT DOES> SWAP CELLS + ;
\ uso:  5 VETOR-DE NOTAS   ->  7 0 NOTAS !   e   0 NOTAS @ .

\ -----------------------------------------------------------------------------
\ 12. ARQUIVOS
\ -----------------------------------------------------------------------------

CREATE LINHA-BUF 256 ALLOT

: MOSTRA-ARQUIVO ( c-addr u -- )
   R/O OPEN-FILE THROW                       ( fid )
   BEGIN
      LINHA-BUF 256 2 PICK READ-LINE THROW   ( fid u flag )
   WHILE
      LINHA-BUF SWAP TYPE CR                 ( fid )
   REPEAT
   DROP CLOSE-FILE THROW ;

: CONTA-LINHAS ( c-addr u -- n )
   R/O OPEN-FILE THROW 0 SWAP                ( n fid )
   BEGIN
      LINHA-BUF 256 2 PICK READ-LINE THROW   ( n fid u flag )
   WHILE
      DROP SWAP 1+ SWAP                      ( n+1 fid )
   REPEAT
   DROP CLOSE-FILE THROW ;

: CAT-DADOS   ( -- )  S" dados.txt" MOSTRA-ARQUIVO ;
: LINHAS-DADOS ( -- ) S" dados.txt" CONTA-LINHAS . ."  linhas" CR ;

\ -----------------------------------------------------------------------------
\ 13. DEMONSTRACAO GERAL
\ -----------------------------------------------------------------------------

: DEMO ( -- )
   SAUDACAO
   ." 7 ao quadrado = "  7 QUADRADO . CR
   ." 5 fatorial    = "  5 FATORIAL . CR
   ." fib(10)       = "  10 FIB . CR
   ." mdc(48,18)    = "  48 18 MDC . CR
   ." 100C em F     = "  100 CELSIUS>F . CR
   ." contagem 0-9  : "  10 CONTAR
   ." primos        : "  LISTA-PRIMOS
   PREENCHE
   ." quadrados     : "  MOSTRA-VETOR
   ." soma do vetor = "  SOMA-VETOR . CR
   ." alfabeto      : "  ALFABETO
   LINHA
   ." Digite  WORDS  para ver todas as palavras disponiveis." CR
   ." Digite  SEE QUADRADO  para ver a definicao de uma palavra." CR
   ." Digite  BYE  para sair do gforth." CR ;

CR .( exemplos.fs carregado. Digite  DEMO  para ver tudo funcionando. ) CR
