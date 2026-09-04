# FORTH COM gforth - PARTE 1: A PILHA

Continuacao: tutorial-gforth-parte2.txt

Cada tema traz o conceito, os comandos para digitar, caixas CUIDADO no ponto exato onde o erro costuma acontecer, e exercicios. Tudo aqui e feito no interpretador interativo: nao ha arquivo para carregar nesta parte.

Os exercicios nao tem gabarito. A conferencia e o proprio interpretador - digite, veja o que sai, e explique para si mesmo por que saiu aquilo.

## TEMA 1 - INSTALACAO E PRIMEIRO CONTATO

### LINUX

```
sudo apt install gforth      # Debian, Ubuntu
sudo dnf install gforth      # Fedora, RHEL
```

### macOS

```
brew install gforth
```

Confira a instalacao em qualquer sistema:

```
gforth --version
```

### WINDOWS

Use o WSL e siga as instrucoes de Linux: e o caminho mais curto e o que da a mesma versao que todo mundo. Nativamente existe

```
winget install --id GNU.Gforth
```

mas o instalador e interativo, exige PowerShell como ADMINISTRADOR, e a versao empacotada e mais antiga que a dos repositorios \*nix.

### O INTERPRETADOR

O comando "gforth" sozinho abre o interpretador interativo (REPL). Depois de cada linha que voce digita, ele responde " ok".

```
gforth
```

Digite isto e veja o 5 aparecer:

```
2 3 + .
```

Para sair:

```
bye
```

Outros modos de uso, para mais tarde:

```
gforth arquivo.fs            carrega o arquivo e fica no interpretador
gforth arquivo.fs -e bye     carrega, executa e sai
```

### CUIDADO - ESPACOS SAO OBRIGATORIOS

Em Forth tudo e separado por espaco, porque tudo e uma PALAVRA. "2 3 +" tem tres palavras; "2 3+" tem duas, e a segunda ("3+") nao existe. Este e o erro numero um de quem vem de outras linguagens.

### EXERCICIOS

- 1.1 Instale o gforth e descubra qual versao voce tem.
- 1.2 Entre no interpretador, calcule 2 3 + . e saia com bye.
- 1.3 Digite uma palavra que nao existe, como xyz. Que mensagem aparece? Guarde-a: voce vai ve-la muitas vezes.
- 1.4 Digite "2 3+" (sem espaco) e compare a mensagem de erro com a do exercicio anterior.

## TEMA 2 - A PILHA E A NOTACAO POSFIXA

Forth nao tem "2 + 3". Tem "2 3 +": primeiro os dados, depois o operador. Isso se chama notacao POSFIXA, ou RPN (Reverse Polish Notation).

Tudo acontece numa PILHA: quem entra por ultimo sai primeiro. Os operadores consomem do topo e devolvem para o topo.

```
2 3 +
```

Nada aparece! O resultado ficou NA PILHA. Para espiar sem consumir:

```
.s
```

Mostra <1> 5 - um item na pilha, e ele e o 5. O "." tira o topo e imprime:

```
.
```

Agora .s mostra <0>: a pilha esta vazia.

```
10 20 30 .s
```

Mostra <3> 10 20 30. O topo e o 30, o mais a DIREITA.

```
+ . .
```

Isso imprime 50 e depois 10: somou 20+30 e imprimiu o resultado, depois imprimiu o 10 que tinha sobrado.

### SEM PARENTESES

Nao existe precedencia de operadores em Forth, porque nao e preciso: a ordem em que voce empilha ja determina a conta.

```
2 3 + 4 * .
```

Da 20, isto e (2+3)\*4.

```
2 3 4 * + .
```

Da 14, isto e 2+(3\*4). Mesmos numeros, mesmos operadores, resultado diferente - o que mudou foi a ordem.

### CUIDADO - STACK UNDERFLOW

Peca um valor que nao existe (um "." com a pilha vazia) e o gforth acusa "Stack underflow". E o erro mais comum de quem comeca. Depois de um erro a pilha pode ficar suja e atrapalhar os comandos seguintes; limpe com:

```
clearstack
```

### EXERCICIOS

- 2.1 Coloque 10 20 30 na pilha e confira com .s. Qual deles e o topo?
- 2.2 Some os dois do topo e imprima; depois imprima o que sobrou. Em que ordem os numeros saem?
- 2.3 Calcule (7+3)\*(5-2) em notacao posfixa.
- 2.4 Escreva em notacao posfixa: 100 / (4 + 1).
- 2.5 Escreva em notacao posfixa: (8-3) \* (8+3).
- 2.6 Provoque um Stack underflow de proposito e recupere-se com clearstack.
- 2.7 Empilhe cinco numeros e imprima todos, um por um. Qual sai primeiro?

## TEMA 3 - ARITMETICA COM INTEIROS

As operacoes basicas consomem dois valores e devolvem um:

```
+  -  *  /  MOD

10 3 - .            \ 7   -> "10 menos 3", nao "3 menos 10"
10 3 / .            \ 3   -> divisao INTEIRA, trunca
10 3 MOD .          \ 1   -> resto da divisao
```

A ordem importa na subtracao e na divisao: o valor que voce empilha primeiro e o da esquerda da conta.

```
10 3 /MOD . .
```

O /MOD faz as duas de uma vez: deixa o resto e o quociente na pilha.

Operacoes de um valor so:

```
-7 ABS .            \ 7
5 NEGATE .          \ -5
7 1+ .              \ 8      soma 1
7 1- .              \ 6      subtrai 1
7 2* .              \ 14     dobra
7 2/ .              \ 3      metade (inteira)
```

Comparacoes de valor:

```
3 9 MIN .           \ 3
3 9 MAX .           \ 9
```

E uma palavra util que evita perda de precisao:

```
100 3 4 */ .        \ 75
```

O \*/ calcula (100\*3)/4 mantendo o produto intermediario em precisao dupla. Fazer "100 3 \* 4 /" daria o mesmo aqui, mas estoura em numeros grandes.

### CUIDADO - A DIVISAO E INTEIRA

"7 2 /" da 3, nao 3.5. Forth classico trabalha com inteiros; nao ha arredondamento, ha truncamento. Se voce precisa da parte fracionaria, ou usa MOD para pegar o resto, ou multiplica antes de dividir:

```
7 2 / .             \ 3
7 2 MOD .           \ 1
7 100 * 2 / .       \ 350, ou seja 3,50 em centesimos
```

### EXERCICIOS

- 3.1 Calcule quantas horas e quantos minutos ha em 500 minutos, usando /MOD.
- 3.2 Converta 100 graus Celsius para Fahrenheit: multiplique por 9, divida por 5, some 32.
- 3.3 Faca a conversao inversa, de 212 Fahrenheit para Celsius.
- 3.4 Calcule a media inteira entre 7 e 10. Depois entre 7 e 8. O que acontece com a fracao?
- 3.5 Descubra se 1234567 e divisivel por 7 usando uma operacao so.
- 3.6 Calcule 15% de 240 usando \*/ e explique por que a ordem dos operandos e essa.

## TEMA 4 - MANIPULANDO A PILHA

Como nao ha variaveis nomeadas para os valores intermediarios, existe um conjunto de palavras que reorganiza a pilha. Elas sao o vocabulario mais importante de Forth, e a notacao ( antes -- depois ) descreve cada uma:

```
DUP    ( a -- a a )         duplica o topo
DROP   ( a -- )             joga fora o topo
SWAP   ( a b -- b a )       troca os dois do topo
OVER   ( a b -- a b a )     copia o SEGUNDO para o topo
ROT    ( a b c -- b c a )   traz o TERCEIRO para o topo
NIP    ( a b -- b )         remove o segundo
TUCK   ( a b -- b a b )     copia o topo para debaixo do segundo
```

E as versoes que trabalham em pares:

```
2DUP   ( a b -- a b a b )
2DROP  ( a b -- )
2SWAP  ( a b c d -- c d a b )
```

Experimente cada uma olhando a pilha antes e depois:

```
5 DUP .s            \ <2> 5 5
* .                 \ 25  -> 5 ao quadrado, sem repetir o 5

1 2 3 .s            \ <3> 1 2 3
DROP .s             \ <2> 1 2
SWAP .s             \ <2> 2 1
OVER .s             \ <3> 2 1 2

clearstack
1 2 3 ROT .s        \ <3> 2 3 1

clearstack
1 2 TUCK .s         \ <3> 2 1 2
```

### A NOTACAO DE PILHA

( a b -- b a ) le-se: "com a embaixo e b no topo, devolve b embaixo e a no topo". O que esta mais a DIREITA e o topo, dos dois lados do --. Essa notacao e a documentacao padrao de Forth, e voce vai escreve-la em toda palavra que definir a partir da Parte 2.

### CUIDADO - ROT MEXE EM TRES

ROT nao "roda a pilha inteira": ela pega o terceiro item e o traz para o topo, empurrando os outros dois para baixo. O que estiver do quarto item para tras nao e tocado. Se voce precisa alcancar o quarto item, ja e sinal de que a palavra devia ser dividida em duas menores.

### EXERCICIOS

Os exercicios 4.1 a 4.4 sao adaptados do Stack Manipulation Tutorial do manual do gforth:  
https://gforth.org/manual/Stack-Manipulation-Tutorial.html

- 4.1 Reimplemente NIP usando apenas SWAP e DROP. Depois reimplemente TUCK usando apenas SWAP e OVER. Confira comparando o .s das duas versoes.
- 4.2 Com 1 2 3 na pilha, produza 3 2 1 usando so as palavras deste tema.
- 4.3 Calcule 17 elevado ao cubo e depois 17 elevado a quarta, sem digitar o numero 17 mais de uma vez.
- 4.4 Com dois valores na pilha, "a" embaixo e "b" no topo, calcule (a-b)\*(a+1).
- 4.5 Com 3 e 4 na pilha, calcule 3\*3 + 4\*4 usando so DUP, SWAP, \* e +.
- 4.6 O que faz ROT ROT ROT? Teste com 1 2 3 e explique o resultado.
- 4.7 Sem usar 2DUP, obtenha o mesmo efeito dela com OVER.
- 4.8 Descubra o que DEPTH faz. Use-a para conferir suas respostas anteriores.

## FIM DA PARTE 1 - continue em tutorial-gforth-parte2.txt
