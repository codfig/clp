# SIMULANDO O DRRACKET NO VS CODE COM A EXTENSÃO MAGIC RACKET

Pré-requisito: racket instalado (Tema 1 de tutorial-racket-parte1.txt).

O DrRacket tem duas metades: a janela de Definitions (onde você edita um arquivo .rkt) e a de Interactions (o REPL, que ganha acesso a tudo que está definido no arquivo assim que você aperta Run). Este material mostra como montar o mesmo fluxo no VS Code usando a extensão Magic Racket - a recomendada pela própria documentação oficial do Racket para uso no VS Code (docs.racket-lang.org/guide/Visual\_Studio\_Code.html).

Vale para qualquer arquivo do curso - os exemplos abaixo usam recursao/funcoes.rkt como arquivo de trabalho, lido ao lado de um tutorial em .txt, por exemplo recursao/tutorial-recursao-parte1.txt.

## LAYOUT SUGERIDO

```
+----------------------------+----------------------------+
|                            |                             |
|  tutorial-recursao-        |  recursao/funcoes.rkt       |
|  parte1.txt (leitura)      |  (você digita aqui)         |
|                            |                             |
+----------------------------+----------------------------+
|  Terminal integrado: REPL do arquivo (Magic Racket)      |
+------------------------------------------------------------+
```

No VS Code: abra o tutorial, Ctrl+\ (ou arraste a aba) para dividir o editor, abra funcoes.rkt do lado. Conforme lê cada TEMA do tutorial, digite a função em funcoes.rkt e carregue no REPL - é o ciclo editar/rodar do DrRacket.

Crie o arquivo antes de começar, com a primeira linha:

```
#lang racket
```

seguida das funções que você for escrevendo (somar, contar, etc.).

## INSTALAÇÃO

1. Ctrl+Shift+X para abrir Extensions, busque Magic Racket (evzen-wybitul.magic-racket) e instale.
2. Opcional, mas recomendado - dá autocompletar e checagem de sintaxe (o equivalente ao "Check Syntax" do DrRacket). No terminal:

```
raco pkg install racket-langserver
```

## USANDO

Com funcoes.rkt aberto no editor:

### CARREGAR O ARQUIVO NO REPL (o Run do DrRacket)

Ícone no canto superior direito do editor, ou pela paleta de comandos (Ctrl+Shift+P, buscar "Racket: Load file in REPL"). Isso abre um terminal dedicado a ESTE arquivo e carrega todas as definições nele - inclusive as que não têm provide, ao contrário de um require comum.

### RECARREGAR DEPOIS DE EDITAR

Editou o arquivo? Rode o mesmo comando de novo (mesmo ícone, ou de novo pela paleta). O REPL desse arquivo recarrega com as mudanças - é literalmente apertar Run de novo.

### TESTAR SÓ UM TRECHO

"Racket: Execute selection in REPL" (atalho Alt+Enter) - selecione um trecho no editor e mande direto para o REPL do arquivo, sem recarregar tudo. Ótimo para testar uma chamada avulsa, tipo (somar '(1 2 3)), sem perder o estado do que já estava carregado.

### REABRIR O REPL

"Racket: Open the REPL for the current file" - reabre o terminal já associado ao arquivo, caso você tenha fechado o painel sem querer.

### CUIDADO - CADA ARQUIVO TEM O SEU PRÓPRIO REPL

Por padrão, cada .rkt aberto ganha um terminal de REPL separado (dá para mudar isso nas configurações da extensão, e usar um terminal único para todos os arquivos). Se você tiver mais de um .rkt aberto, confira qual terminal está em foco antes de digitar um teste.

### CUIDADO - A EXTENSÃO USA O racket DA SUA MÁQUINA

Magic Racket chama o mesmo racket e raco já instalados no sistema - o mesmo que você usaria digitando "racket" direto no terminal. Se "racket --version" não funcionar num terminal comum, a extensão também não vai funcionar: resolva a instalação primeiro (Tema 1 de tutorial-racket-parte1.txt).

### UM ATALHO DE TECLADO PARA "Load file in REPL"?

Não existe atalho padrão de fábrica para esse comando. Para criar um: abra Ctrl+K Ctrl+S (Keyboard Shortcuts), busque o comando na lista e clique no lápis para atribuir uma tecla - fica com a sensação do botão Run do DrRacket.

## FIM
