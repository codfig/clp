# Aula 02 - Lisp + recursão

Material da aula de 28/08/2026. Os tutoriais ficam nas pastas `lisp/` e
`recursao/`, junto com as bibliotecas de exemplos em `.rkt`; os links abaixo
apontam para as versões em Markdown, na ordem sugerida de leitura.

## Racket (pasta `lisp/`)

1. [Racket na linha de comando - Parte 1: dos átomos às listas](../lisp/tutorial-racket-parte1.md)
   Temas 1 a 8: instalação, o REPL, a família Lisp, s-expressions, átomos,
   `car`/`cdr`/`cons` e a lista como syntactic sugar.
2. [Racket na linha de comando - Parte 2: eval, define e condicionais](../lisp/tutorial-racket-parte2.md)
   Temas 9 a 15: `eval`, apóstrofo, `define`, predicados, `if` e `cond`.
   Exemplos prontos em [`lisp/exemplos-parte2.rkt`](../lisp/exemplos-parte2.rkt).
3. [Simulando o DrRacket no VS Code com a extensão Magic Racket](../lisp/dr-racket-or-vscode-repl.md)
   Guia de apoio: como reproduzir o ciclo editar/Run/REPL do DrRacket dentro
   do VS Code. Leia quando quiser sair do terminal puro.

## Recursão (pasta `recursao/`)

4. [Programação recursiva: processamento de listas em Racket](../recursao/tutorial-recursao-parte1.md)
   Temas 16 a 28: o esqueleto de toda função recursiva sobre listas, casos
   base, `lambda` e `my-map`. Pré-requisito: os Temas 1 a 12 dos tutoriais de
   Racket acima. Exemplos prontos em
   [`recursao/exemplos-parte1.rkt`](../recursao/exemplos-parte1.rkt).
