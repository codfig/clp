# Aula 01 - Lex/Sint/Sem + regex + Forth

## Três níveis de uma linguagem.
- "Linguagem" é um conceito bem amplo: línguas naturais, como japonês e italiano, linguagens formais, como na matemática, na lógica e na programação, notação musical, podendo incluir vários fenômenos observados na reino animal, como a "dança" das abelhas, o canto das baleias.
- Qualquer linguagem pode ser abordada em três níveis: léxico, sintático e semântico, ou níveis do léxico, da sintaxe e da semântica.
- Três frases incompreensíveis
   - Adeno toio aiapote dunteteton. (Palavras desconhecidas, falha no nível léxico)
   - Dorme a ante 98 oi tenda claramente foi. (Palavras conhecidas, mas combinação exótica, falha no nível sintático)
   - A hipotenusa voadora calvagou uma nuvem tangente ao quadrado. (Paravras conhecidas, estrutura sujeito-verbo-predicado, falha no nível semântico)
- Ideias:
  - Nível léxico: palavra, dicionário, vocabulário
  - Nível sintático: estrutura, forma, gramática
  - Nível semântico: significado, sentido
- Linguagens de programação
   - Nível léxico: palavras reservadas (if, for), literais de números, identificadores (isto é, nomes de variáveis e funções, criadas pelo programador, etc.)
   - Nível sintático - regras
   - Nível semântico - o que é um condicional, o que é uma repetição, o que é uma função, isto é, tudo sobre o que é fazer um algoritmo/programa numa máquina

## Expressões regulares (pasta `regex/`)

1. [Expressões regulares com egrep - Parte 1: fundamentos](regex/tutorial-grep-parte1.md)
    Dados de teste em
   [`regex/dados.txt`](regex/dados.txt).
2. [Expressões regulares com egrep - Parte 2: técnicas avançadas](regex/tutorial-grep-parte2.md)
   Usa também [`regex/entrada.txt`](regex/entrada.txt), com dados
   sujos de propósito.

## Forth (pasta `forth/`)

3. [Forth com gforth - Parte 1: a pilha](forth/tutorial-gforth-parte1.md)
   Temas 1 a 4: a pilha e a notação posfixa (RPN), aritmética com inteiros e
   as palavras de manipulação da pilha (`DUP`, `SWAP`, `DROP`, `OVER`,
   `ROT`...). Tudo no interpretador interativo.
4. [Forth com gforth - Parte 2: definindo a sua linguagem](forth/tutorial-gforth-parte2.md)
   NÃO FOI VISTO.
