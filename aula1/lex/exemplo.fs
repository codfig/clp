\ exemplo.fs - entrada de teste do analisador lexico
\ Este arquivo exercita TODAS as classes de token reconhecidas pelo lexforth.

( comentario entre parenteses, numa linha so )

( comentario que
  atravessa varias
  linhas )

\ ---- numeros ----
42  -17  +58  0  1000000  12.
$FF  $deadBEEF  0x1F  -$10
%1011  %11111111
3.14e  1.5e-3  2e10  -0.5e0
'A'  'z'  '0'

\ ---- strings e impressao ----
S" uma string literal"
C" string contada"
." texto impresso na tela"
ABORT" mensagem de erro"
.( isto e impresso durante a compilacao )

\ ---- definicoes ----
: QUADRADO ( n -- n*n ) DUP * ;
VARIABLE CONTADOR
100 CONSTANT MAXIMO
CREATE VETOR 10 CELLS ALLOT
: CONSTANTE-NOMEADA CREATE , DOES> @ ;

\ ---- controle de fluxo ----
: SINAL
   DUP 0 > IF ." positivo"
   ELSE DUP 0 < IF ." negativo"
   ELSE ." zero"
   THEN THEN DROP CR ;

: CONTAR 10 0 ?DO I . LOOP CR ;
: PARES  20 0 ?DO I . 2 +LOOP CR ;
: ACHA   10 0 ?DO I 5 = IF LEAVE THEN LOOP ;
: LOOP2  BEGIN DUP . 1- DUP 0= UNTIL DROP ;
: LOOP3  BEGIN DUP WHILE TUCK MOD REPEAT DROP ;
: FAT    DUP 1 <= IF DROP 1 ELSE DUP 1- RECURSE * THEN ;

\ ---- pilha, aritmetica, comparacao, memoria ----
: MISTURA
   DUP DROP SWAP OVER ROT -ROT NIP TUCK 2DUP 2DROP >R R> R@ DEPTH
   + - * / MOD /MOD */ 1+ 1- 2* 2/ NEGATE ABS MIN MAX AND OR XOR INVERT
   = <> < > <= >= 0= 0< 0> TRUE FALSE WITHIN
   @ ! +! C@ C! 2@ 2! CELLS CELL+ ALLOT HERE
   . .S U. EMIT KEY TYPE CR SPACE SPACES ;

\ ---- ponto flutuante ----
: AREA FDUP F* 3.14159265e F* ;

\ ---- palavras nao reservadas (identificadores do usuario) ----
minha-palavra  outra_palavra  palavra?  ajusta!  <compara>  x2  a1b2c3

\ ---- casos limite do analisador ----
12ABC        \ NAO e o numero 12 seguido de ABC: e uma palavra so
1e           \ float com expoente vazio
-            \ o sinal sozinho e a palavra de subtracao
.            \ o ponto sozinho e a palavra de impressao
,            \ a virgula sozinha e a palavra de compilacao
