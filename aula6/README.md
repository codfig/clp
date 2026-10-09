# Aula 06 - Recursão com acumuladores (reduce) + a linguagem LET

Material da aula de 09/10/2026. São dois tutoriais independentes, cada um na
sua pasta, com as bibliotecas de exemplos ao lado; os links abaixo apontam
para as versões em Markdown, na ordem sugerida de leitura.

## Recursão com acumuladores (pasta `acumuladores/`)

1. [Recursão com acumuladores: de somar a reduce, em Racket e em SML](../acumuladores/tutorial-acumuladores.md)
   Temas 68 a 80: a recursão que trabalha "na volta" e a que trabalha "na
   ida", com um acumulador; recursão de cauda e processo iterativo (o `trace`
   do Racket mostra a diferença); funções de resultado numérico (`somar`,
   `contar`), lógico (`comprimento-par?`, `sem-vizinhos-iguais?`) e em lista
   (`reverse`, `dobrar`, `my-map`, `my-filter`, `enumerar`, `my-append`);
   o padrão comum a todas elas, `foldl`, e o seu gêmeo `foldr`; os muitos
   nomes da mesma ideia (`reduce`, `fold`, `inject`, `aggregate`,
   `accumulate`...). Cada função aparece nas duas linguagens. Exemplos
   prontos em [`acumuladores/exemplos.rkt`](../acumuladores/exemplos.rkt) e
   [`acumuladores/exemplos.sml`](../acumuladores/exemplos.sml).

## A linguagem LET (pasta `interpretador-let/`)

2. [A linguagem LET: um interpretador e dois compiladores, em Standard ML](../interpretador-let/tutorial-let.md)
   Temas 81 a 95: a primeira linguagem do livro *Essentials of Programming
   Languages* (Friedman e Wand, 3ª ed., MIT Press), implementada inteira em
   SML: sintaxe abstrata com `datatype`, valores, ambientes, o interpretador
   `valueOf`, análise léxica e análise sintática descendente recursiva; depois
   um compilador de LET para Racket e outro para Forth, e os três rodando lado
   a lado. Termina com os exercícios do livro (capítulo 3). Código completo em
   [`interpretador-let/let.sml`](../interpretador-let/let.sml).

Pré-requisitos: os Temas 16 a 67 (recursão em Racket e Standard ML, aulas
[02](../aula2/README.md), [03](../aula3/README.md) e
[04](../aula4/README.md)). O tutorial de LET usa o de acumuladores e, na parte
do compilador para Forth, a parte 1 de Forth da [Aula 01](../aula1/README.md).

## Para rodar

```
racket -i -e '(enter! "exemplos.rkt")'    # dentro de acumuladores/
sml exemplos.sml                          # dentro de acumuladores/
sml let.sml                               # dentro de interpretador-let/
```

A função `comparar`, de `let.sml`, chama `racket` e `gforth` pelo terminal;
para ela funcionar, os dois precisam estar instalados (o gforth é o da
Aula 01: `sudo apt install gforth`).
