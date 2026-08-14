\ =============================================================================
\ pratica.fs - esqueletos dos exercicios (veja roteiro.txt)
\ =============================================================================
\ Substitua cada  TODO  pela sua implementacao, salve e recarregue:
\     INCLUDE pratica.fs
\     TESTES
\ Enquanto uma palavra nao estiver implementada, TESTES para nela com uma
\ mensagem. Implemente uma de cada vez, na ordem.
\ =============================================================================

: TODO   ( -- )  TRUE ABORT" <<< ainda nao implementado - edite pratica.fs" ;

\ --- BLOCO A -----------------------------------------------------------------

: TRIPLO       ( n -- 3n )        TODO ;
: HIPOTENUSA2  ( a b -- a2+b2 )   TODO ;
: TROCO        ( centavos -- resto moedas )  TODO ;
: ENTRE?       ( n min max -- flag )         TODO ;

\ --- BLOCO B -----------------------------------------------------------------

: MAIORIDADE   ( idade -- )       TODO ;
: BISSEXTO?    ( ano -- flag )    TODO ;
: SOMA-PARES   ( n -- soma )      TODO ;
: POTENCIA     ( base exp -- r )  TODO ;
: CONTA-DIGITOS ( n -- qtd )      TODO ;

\ --- BLOCO C -----------------------------------------------------------------

CREATE NOTAS 5 CELLS ALLOT           \ o vetor ja esta criado
: NOTA[]         ( i -- addr )    TODO ;
: PREENCHE-NOTAS ( -- )           TODO ;   \ 7 8 9 6 10
: MEDIA-NOTAS    ( -- media )     TODO ;
: MAIOR-NOTA     ( -- max )       TODO ;
: ACUMULADOR-NOMEADO ( "nome" -- ) TODO ;

\ =============================================================================
\ TESTES
\ =============================================================================

: TESTA ( obtido esperado c-addr u -- )
   ." teste " TYPE ." : "
   2DUP = IF   ." OK"  2DROP
          ELSE ." FALHOU (esperado " . ." obtido " . ." )"
   THEN CR ;

: TESTES ( -- )
   CR ." --- BLOCO A ---" CR
   5 TRIPLO         15  S" TRIPLO"       TESTA
   3 4 HIPOTENUSA2  25  S" HIPOTENUSA2"  TESTA
   90 TROCO SWAP DROP 3 S" TROCO"        TESTA
   7 1 10 ENTRE?    -1  S" ENTRE? (sim)" TESTA
   99 1 10 ENTRE?    0  S" ENTRE? (nao)" TESTA

   CR ." --- BLOCO B ---" CR
   ." MAIORIDADE 20 -> " 20 MAIORIDADE
   ." MAIORIDADE 12 -> " 12 MAIORIDADE
   2024 BISSEXTO?   -1  S" BISSEXTO? 2024" TESTA
   1900 BISSEXTO?    0  S" BISSEXTO? 1900" TESTA
   2000 BISSEXTO?   -1  S" BISSEXTO? 2000" TESTA
   10 SOMA-PARES    20  S" SOMA-PARES"     TESTA
   2 10 POTENCIA  1024  S" POTENCIA"       TESTA
   12345 CONTA-DIGITOS 5 S" CONTA-DIGITOS" TESTA

   CR ." --- BLOCO C ---" CR
   PREENCHE-NOTAS
   MEDIA-NOTAS       8  S" MEDIA-NOTAS"  TESTA
   MAIOR-NOTA       10  S" MAIOR-NOTA"   TESTA
   CR ." (o exercicio 12 teste manualmente:" CR
   ."   ACUMULADOR-NOMEADO VENDAS  100 VENDAS +!  50 VENDAS +!  VENDAS @ . )" CR ;

CR .( pratica.fs carregado. Digite  TESTES  para conferir. ) CR
