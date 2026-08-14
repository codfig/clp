===============================================================================
 ANALISADOR LEXICO DE FORTH - implementacao em C com regex POSIX
===============================================================================
 Arquivos desta pasta:
   lexforth.c   - o analisador (fonte unico, ~380 linhas)
   exemplo.fs   - entrada de teste com TODAS as classes de token
   erros.fs     - entrada com erros lexicais propositais
   Makefile     - alvos de compilacao e teste
   README.txt   - este arquivo

===============================================================================
 1. COMPILANDO
===============================================================================
 O programa usa <regex.h>, a biblioteca de expressoes regulares do POSIX.

 IMPORTANTE: MinGW e MSVC NAO possuem <regex.h>. No Windows use o Cygwin
 (que ja esta instalado nesta maquina) ou o WSL.

 Com o gcc do Cygwin, direto:

     C:\cygwin64\bin\gcc -std=gnu99 -Wall -Wextra -O2 -o lexforth lexforth.c

 No Git Bash, a mesma coisa:

     /c/cygwin64/bin/gcc -std=gnu99 -Wall -Wextra -O2 -o lexforth lexforth.c

 Com make (precisa instalar: no setup do Cygwin, pacote "make"):

     make          compila
     make teste    lista os tokens de exemplo.fs
     make erros    demonstra a deteccao de erro lexico
     make resumo   so as estatisticas
     make curso    roda sobre o material de Forth da aula
     make limpo    apaga o executavel

===============================================================================
 2. USANDO
===============================================================================
     ./lexforth exemplo.fs              lista todos os tokens
     ./lexforth -s ../forth/exemplos.fs so o resumo estatistico
     ./lexforth -c exemplo.fs           omite os comentarios da listagem
     cat arquivo.fs | ./lexforth        le da entrada padrao
     ./lexforth -h                      ajuda

 Codigo de saida: 0 se tudo certo, 2 se houve erro lexico.
 Isso permite usar o analisador dentro de scripts e Makefiles.

 Saida de exemplo:

     linha:col  tipo            lexema
     ---------------------------------------------------------
        25:1    DEFINICAO       ":"
        25:3    PALAVRA         "QUADRADO"
        25:12   COMENTARIO      "( n -- n*n )"
        25:25   PILHA           "DUP"
        25:29   ARITMETICA      "*"
        25:31   DEFINICAO       ";"

===============================================================================
 3. COMO O ANALISADOR FUNCIONA
===============================================================================
 O algoritmo e o classico "tabela de regras + maximal munch":

   1. Um cursor caminha pelo texto, da esquerda para a direita.
   2. Em cada posicao, as regexes da tabela ESTRUTURAIS sao testadas NA ORDEM,
      todas ancoradas em ^ - o casamento tem que comecar exatamente no cursor.
   3. A primeira que casar define o token, e o cursor avanca o tamanho do
      casamento.
   4. Se nada casar, o caractere vira um token de ERRO e o cursor anda 1.

 A ORDEM DA TABELA E O ALGORITMO. Regras especificas vem antes das gerais:

     comentarios  ->  strings  ->  floats  ->  hex/bin/char  ->  inteiros
                                                              ->  PALAVRA

 Se INTEIRO viesse antes de FLOAT, "3.14e" seria quebrado em "3." e "14e".
 Se PALAVRA (que casa qualquer coisa sem espaco) viesse primeiro, ela
 engoliria tudo e nenhuma outra regra seria alcancada.

 DUAS FASES
 ----------
 Fase 1 (FORMA):      a regex reconhece o formato do lexema.
 Fase 2 (SIGNIFICADO): se o resultado foi PALAVRA, uma segunda tabela de
                       regexes ancoradas em ^...$ classifica em CONTROLE,
                       PILHA, ARITMETICA, MEMORIA, ENTRADA-SAIDA, etc.

 Essa separacao e a mesma que o lex/flex produz. Ela existe porque a forma de
 "DUP" e de "MINHA-PALAVRA" e identica - as duas sao sequencias sem espaco. O
 que as distingue nao e a sintaxe, e o dicionario.

===============================================================================
 4. A TABELA DE EXPRESSOES REGULARES
===============================================================================
 Todas compiladas com REG_EXTENDED | REG_ICASE (Forth ignora maiusculas).

 TIPO           REGEX                                    EXEMPLO
 -------------  ---------------------------------------  -------------------
 ESPACO         ^[ \t\r\n]+                              (descartado)
 COMENTARIO     ^\\([ \t\r][^\n]*)?                      \ ate o fim da linha
 STRING         ^\.\([^)\n]*\)                           .( imprime )
 COMENTARIO     ^\([ \t\r\n][^)]*\)                      ( n -- n*n )
 STRING         ^(S"|C"|\."|ABORT")[^"\n]*"              S" texto"
 FLOAT          ^[+-]?[0-9]+(\.[0-9]*)?[eE][+-]?[0-9]*   3.14e  1.5e-3
 HEXADECIMAL    ^[+-]?(\$|0[xX])[0-9A-Fa-f]+             $FF  0x1F
 BINARIO        ^[+-]?%[01]+                             %1011
 CARACTERE      ^'[^']'                                  'A'
 INTEIRO        ^[+-]?[0-9]+\.?                          42  -17  12.
 PALAVRA        ^[^ \t\r\n]+                             QUADRADO  <compara>

 Detalhes que valem a prova:

 a) A regra de COMENTARIO de linha casa a barra invertida SOZINHA tambem
    (o grupo final e opcional), porque em Forth "\" no fim da linha e valido.

 b) A regra de ( comentario ) exige um espaco depois do parentese. Isso e
    Forth de verdade: "(" e uma PALAVRA, e palavras terminam em espaco.
    Por isso "(1 2)" nao e comentario, e ".(" e outra palavra completamente
    diferente - e por isso a regra de ".(" vem antes.

 c) As strings usam [^"\n] e nao [^"]. A proibicao da quebra de linha e
    deliberada: sem ela, uma aspa esquecida engole o resto do arquivo ate
    encontrar a proxima aspa, e o erro aparece a dezenas de linhas do lugar
    onde realmente esta. Ja o comentario ( ... ) PODE atravessar linhas,
    entao a regra dele usa [^)] mesmo.

 d) O comentario ( ... ) atravessando linhas e o unico token multi-linha.
    Como regexec nao recebe REG_NEWLINE, o "." e as classes negadas casam
    o \n normalmente, e isso funciona sem nenhum tratamento especial.

===============================================================================
 5. O QUE REGEX SOZINHA NAO RESOLVE
===============================================================================
 Este e o ponto mais importante da atividade.

 PROBLEMA 1: fronteira de token (maximal munch nao basta)
 --------------------------------------------------------
 Em Forth, "12ABC" e UMA palavra, nao o numero 12 seguido de ABC. Mas a regex
 de INTEIRO casa o prefixo "12" alegremente.

 A solucao seria um lookahead - "casa digitos SE o proximo caractere for
 delimitador". ERE POSIX nao tem lookahead. Entao a condicao e verificada em
 C: o campo needs_delim na tabela marca as regras numericas, e apos o
 casamento o programa confere se o caractere seguinte e espaco, tab, \n ou
 fim de arquivo. Se nao for, a regra e recusada e a busca continua - e o
 lexema acaba caindo em PALAVRA, como deveria.

 Teste isso: a linha "12ABC" em exemplo.fs sai classificada como PALAVRA.

 PROBLEMA 2: palavras-chave nao sao uma questao sintatica
 --------------------------------------------------------
 "DUP" e "MINHA-PALAVRA" tem exatamente a mesma forma. Nenhuma regex consegue
 separar as duas, porque a diferenca esta no dicionario, nao na escrita. Dai
 a segunda fase de classificacao.

 E mais: em Forth o proprio programador cria palavras novas em tempo de
 compilacao. Um analisador lexico 100% correto para Forth teria que executar
 o codigo enquanto o le - Forth nao tem uma gramatica fixa. O que este
 programa faz e o que qualquer editor de texto faz: reconhecer o conjunto
 padrao e tratar o resto como identificador.

 PROBLEMA 3: contexto
 --------------------
 O analisador nao sabe se esta dentro ou fora de uma definicao (: ... ;).
 Para isso ja seria preciso um analisador SINTATICO, com uma pilha de estados.
 Regex reconhece linguagens regulares; aninhamento exige mais poder.

===============================================================================
 6. RESULTADOS MEDIDOS
===============================================================================
 Rodando sobre o material de Forth da propria aula:

   ./lexforth -s ../forth/exemplos.fs         816 tokens, 0 erros
   ./lexforth -s ../forth/pratica/pratica.fs  217 tokens, 0 erros
   ./lexforth -s exemplo.fs                   241 tokens, 0 erros
   ./lexforth erros.fs                         17 tokens, 2 erros (saida 2)

===============================================================================
 7. EXERCICIOS
===============================================================================
 L1. Acrescente o token DOUBLE para literais de precisao dupla (o "12." de
     hoje esta sendo classificado como INTEIRO).

 L2. Melhore a RECUPERACAO DE ERRO do comentario aberto. Hoje, ao encontrar
     um "(" sem ")", o analisador consome todo o resto do arquivo num unico
     token de ERRO e nao reporta mais nada. Teste assim:

         printf ': OK 1 2 + ;\n( comentario sem fechar\n: DEPOIS 3 ;\n' > t.fs
         ./lexforth t.fs

     Repare que ": DEPOIS 3 ;" desaparece da listagem. Faca o analisador
     retomar no inicio da proxima linha (como ja acontece com as strings) e
     compare: qual das duas estrategias de recuperacao produz mensagens de
     erro mais uteis num arquivo com varios problemas?

 L3. Acrescente a opcao -n para imprimir apenas os tokens de um tipo
     (exemplo: ./lexforth -n CONTROLE exemplo.fs).

 L4. Meca a frequencia das palavras do usuario (tipo PALAVRA) e mostre as 10
     mais usadas. Da para resolver sem tocar no C, so com o pipeline do
     tutorial de regex - as duas metades da aula se encontram aqui:

         ./lexforth ../forth/exemplos.fs | egrep PALAVRA \
           | egrep -o '"[^"]*"$' | sort | uniq -c | sort -rn | head

     Depois implemente a mesma contagem dentro do lexforth.c, com uma tabela
     de simbolos, e compare o esforco.

 L5. Implemente o rastreamento de definicoes: ao encontrar ":", registre o
     proximo token como uma palavra DEFINIDA PELO USUARIO e, a partir dai,
     classifique os usos dela como USUARIO em vez de PALAVRA. Repare que isso
     ja NAO e analise lexica - voce esta construindo uma tabela de simbolos.

 L6. Compare com a ferramenta pronta: escreva a mesma especificacao em flex
     (arquivo .l) e veja quantas linhas de codigo voce economiza.
===============================================================================
