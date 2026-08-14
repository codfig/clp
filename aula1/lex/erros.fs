\ erros.fs - entrada com erros lexicais PROPOSITAIS
\ Use para ver o analisador reportando problema:  ./lexforth erros.fs
\ O programa termina com codigo de saida 2 quando encontra erro lexico.

: PALAVRA-OK 42 DUP * ;

\ erro 1: string sem as aspas de fechamento
: DEFEITO1 S" esqueci de fechar a string ;

\ erro 2: outra string aberta, agora com ."
: DEFEITO2 ." tambem esqueci ;
