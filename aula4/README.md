# Aula 04 - Standard ML + Avaliação P1

Material da aula de 11/09/2026. A aula tem duas metades: o início de
**Standard ML**, primeira linguagem estaticamente tipada do curso, e, em
seguida, a **Avaliação P1** (veja [avaliacao1/](../avaliacao1/)).

Os tutoriais ficam na pasta `sml/`, junto com as bibliotecas de exemplos em
`.sml`; os links abaixo apontam para as versões em Markdown, na ordem sugerida
de leitura.

## Standard ML (pasta `sml/`)

1. [Standard ML - Parte 1: dos tipos básicos aos tipos algébricos](../sml/tutorial-sml-parte1.md)
   Temas 42 a 55: de onde vem ML (Robin Milner, o assistente de provas LCF,
   a evolução até SML e OCaml), instalação do SML/NJ, tipos básicos, `val`,
   `fun`, `if`, `let`, recursão, casamento de padrões, tipos produto (tuplas
   e records) e tipos soma (`datatype`). Exemplos prontos em
   [`sml/exemplos-parte1.sml`](../sml/exemplos-parte1.sml).
2. [Standard ML - Parte 2: listas, polimorfismo e inferência](../sml/tutorial-sml-parte2.md)
   Temas 56 a 67: a lista construída por nós com `Lizt`/`Kons`/`Nihil`, as
   funções de recursão da Aula 03 reescritas em SML, polimorfismo paramétrico
   (`'a`), ordem superior e currying, a lista nativa como açúcar sintático,
   inferência de tipos (Hindley-Milner) e a comparação entre dinamicamente e
   estaticamente tipado. Exemplos prontos em
   [`sml/exemplos-parte2.sml`](../sml/exemplos-parte2.sml) (Temas 56 a 59) e
   [`sml/exemplos-parte2-poli.sml`](../sml/exemplos-parte2-poli.sml)
   (Temas 60 a 67).

Pré-requisito das duas partes: os Temas 1 a 41, dos tutoriais de Racket e de
recursão das aulas [02](../aula2/README.md) e [03](../aula3/README.md) - a
parte 2 reescreve em SML, uma por uma, as funções que você escreveu lá.

## Regra da casa

Nos Temas 42 a 63 **toda** função e **todo** valor levam anotação de tipo
explícita, mesmo sendo opcional na linguagem. A inferência de tipos só é
apresentada no Tema 64, e é justamente esse o motivo: quem escreve o tipo
aprende a pensar no tipo.

## Instalação rápida

```
sudo apt install smlnj        # Debian, Ubuntu
sudo dnf install smlnj        # Fedora, RHEL
brew install smlnj            # macOS
```

No Windows, use o WSL e siga as instruções de Linux. Sem poder instalar nada,
o <https://sosml.org> roda Standard ML dentro do navegador e dá conta de todos
os exemplos. O Tema 43 detalha as alternativas.
