===============================================================================
 MiniForth - subconjunto minimo de Forth e seu analisador lexico
===============================================================================
 miniforth.c   analisador completo em 155 linhas (114 sem comentarios)
 exemplo.mf    programa MiniForth exercitando as 4 classes lexicas
 erros.mf      programa com erro lexico proposital
 Makefile      compilacao e testes

 A versao completa, para Forth de verdade, esta em ../lex (443 linhas).

===============================================================================
 1. DEFINICAO DA LINGUAGEM
===============================================================================
 MiniForth tem QUATRO classes lexicas e DEZESSEIS palavras reservadas.

 CLASSE       FORMA                       EXEMPLO
 -----------  --------------------------  --------------------------------
 espaco       [ \t\r\n]+                  (descartado)
 comentario   ( ... )                     ( n -- n*n )   pode ter varias linhas
 inteiro      [+-]?[0-9]+                 42   -17   +58
 palavra      qualquer coisa sem espaco   QUADRADO  minha-palavra  <=>

 As 16 reservadas, divididas em duas categorias:

   CONTROLE   :  ;  IF  ELSE  THEN
   OPERADOR   +  -  *  /  DUP  DROP  SWAP  OVER  @  !  .  CR

 Tudo o mais que nao for espaco, comentario ou inteiro e PALAVRA - isto e,
 um identificador definido pelo programador.

 Como em Forth, maiusculas e minusculas nao se distinguem, e todo token
 termina em espaco em branco.

===============================================================================
 2. COMPILANDO E RODANDO
===============================================================================
 Precisa de <regex.h> POSIX: use Cygwin ou WSL (MinGW e MSVC nao tem).

     C:\cygwin64\bin\gcc -std=gnu99 -Wall -Wextra -O2 -o miniforth miniforth.c

     ./miniforth exemplo.mf      lista os tokens
     ./miniforth erros.mf        demonstra o erro lexico (sai com codigo 2)
     cat prog.mf | ./miniforth   le da entrada padrao

===============================================================================
 3. COMO FUNCIONA (o programa inteiro em 5 passos)
===============================================================================
 1. Um cursor caminha pelo texto da esquerda para a direita.
 2. Em cada posicao, as 4 regexes da tabela REGRAS sao testadas NA ORDEM,
    ancoradas em ^ - o casamento tem que comecar no cursor.
 3. A primeira que casar define o token; o cursor avanca o tamanho do
    casamento (isto e o "maximal munch").
 4. Se o resultado foi PALAVRA, as 2 regexes da tabela CHAVES, ancoradas em
    ^...$, decidem se ela e CONTROLE, OPERADOR ou fica como PALAVRA mesmo.
 5. Linha e coluna sao atualizadas contando os \n consumidos.

 As duas tabelas juntas ocupam 12 linhas de codigo. Trocar a linguagem
 reconhecida significa editar essas 12 linhas - o motor nao muda.

===============================================================================
 4. OS QUATRO PROBLEMAS QUE ISTO DEMONSTRA
===============================================================================
 Foi por causa deles que o subconjunto ficou com estas classes, e nao menos.

 (a) A ORDEM DAS REGRAS E O ALGORITMO
     PALAVRA casa qualquer coisa sem espaco, inclusive "42". Se ela viesse
     antes de INTEIRO, nenhum numero seria reconhecido. Experimente trocar as
     duas linhas na tabela REGRAS e rodar de novo: o resumo perde a categoria
     INTEIRO inteira.

 (b) FRONTEIRA DE TOKEN: regex sozinha nao resolve
     "12ABC" e UMA palavra, nao o inteiro 12 seguido de ABC. Mas a regex de
     inteiro casa o prefixo "12" alegremente. A solucao seria um lookahead
     ("digitos SE o proximo caractere for delimitador"), e ERE POSIX nao tem
     lookahead. Por isso o campo "delim" na tabela: apos o casamento, o
     programa confere em C se o proximo caractere e delimitador; se nao for,
     recusa a regra e continua procurando - e o lexema cai em PALAVRA.
     Veja a linha 26 do exemplo.mf.

 (c) FORMA nao e SIGNIFICADO
     "DUP" e "minha-palavra" tem exatamente a mesma forma: sequencias sem
     espaco. Nenhuma regex separa as duas, porque a diferenca esta no
     dicionario, nao na escrita. Dai a segunda fase. E a mesma arquitetura
     que o lex/flex gera automaticamente.

 (d) TOKEN QUE ATRAVESSA LINHAS
     O comentario ( ... ) pode ocupar varias linhas. E por isso que o
     programa le o arquivo INTEIRO para a memoria em vez de processar linha
     a linha, e tambem por isso que linha/coluna precisam ser contadas na
     mao, varrendo o lexema consumido.

===============================================================================
 5. O QUE FICOU DE FORA (de proposito)
===============================================================================
 Comparado com ../lex/lexforth.c, MiniForth nao tem: ponto flutuante,
 hexadecimal, binario, literal de caractere, strings (S" C" ." ABORT"),
 comentario de linha com \, e as 7 categorias semanticas de palavras.

 Nada disso acrescentaria um problema NOVO ao analisador - so mais linhas na
 tabela. Essa e a licao de dimensionamento: o tamanho de um analisador lexico
 nao vem do tamanho da linguagem, vem do numero de CLASSES DE TOKEN e das
 irregularidades entre elas.

 O que MiniForth tambem nao faz, e nenhum analisador lexico faz: saber se
 esta dentro ou fora de uma definicao ( : ... ; ). Aninhamento exige um
 analisador SINTATICO. Regex reconhece linguagens regulares, e so.

===============================================================================
 6. EXERCICIOS
===============================================================================
 M1. Inverta a ordem de INTEIRO e PALAVRA na tabela REGRAS, recompile e
     explique a saida.

 M2. Acrescente a classe FLOAT ( 3.14 ) mantendo INTEIRO funcionando.
     Quantas linhas foram necessarias? Onde a regra teve que entrar?

 M3. Acrescente o comentario de linha com \ (barra ate o fim da linha).
     Cuidado: em Forth a barra precisa ser seguida de espaco.

 M4. Hoje um comentario aberto e reportado e o analisador retoma na linha
     seguinte. Faca o mesmo para uma classe nova de string " ... ".

 M5. Conte quantas palavras DIFERENTES o programa define (tokens PALAVRA que
     vem logo depois de um : ). Repare que, ao guardar essa lista, voce
     comecou a construir uma tabela de simbolos - e saiu da analise lexica.

 M6. Escreva a mesma especificacao em flex (arquivo .l) e compare o tamanho.
===============================================================================
