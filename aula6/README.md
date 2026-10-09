# Aula 06 - Recursão com acumuladores (reduce)

Material da aula de 09/10/2026. O tutorial fica na pasta `acumuladores/`,
junto com as bibliotecas de exemplos em `.rkt` e `.sml`; o link abaixo aponta
para a versão em Markdown.

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

Pré-requisitos: os Temas 16 a 67 (recursão em Racket e Standard ML, aulas
[02](../aula2/README.md), [03](../aula3/README.md) e
[04](../aula4/README.md)).

A continuação, com a linguagem LET (que usa os acumuladores no scanner e no
compilador para Forth), está na [Aula 07](../aula7/README.md).

## Para rodar

```
racket -i -e '(enter! "exemplos.rkt")'    # dentro de acumuladores/
sml exemplos.sml                          # dentro de acumuladores/
```
