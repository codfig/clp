# A LINGUAGEM LET: UM INTERPRETADOR E DOIS COMPILADORES, EM STANDARD ML

Pré-requisito: os tutoriais de Standard ML (Temas 42 a 67, pasta sml/), em especial `datatype` (Tema 53), casamento de padrões (Tema 51) e listas nativas (Tema 62); o tutorial de acumuladores (Temas 68 a 80, pasta acumuladores/); a parte 1 de Forth (Temas 1 a 4, aula1/forth/).  
Biblioteca....: let.sml (mesma pasta)

Referência: Daniel P. Friedman e Mitchell Wand, *Essentials of Programming Languages*, 3ª edição, MIT Press, 2008 - o "EOPL". A linguagem LET é a da seção 3.2 do livro.

No exercício 67.3 você foi convidado a escrever, em miniatura, um interpretador para uma linguagem com `let`. Este tutorial faz isso por inteiro, com uma linguagem de verdade - a primeira de uma sequência que o EOPL usa para explicar, uma por uma, as ideias que formam as linguagens de programação. E depois vai além: escreve dois COMPILADORES para a mesma linguagem, um que traduz para Racket e outro que traduz para Forth.

A biblioteca let.sml traz todo o código do texto, na mesma ordem, pronto para carregar:

```
sml let.sml
```

Ela contém apenas o código do texto - nenhuma resposta de exercício.

## TEMA 81 - O EOPL E A LINGUAGEM LET

*Essentials of Programming Languages* é um livro sobre como linguagens de programação funcionam por dentro, e o método dele é um só: para entender uma ideia, escreva um interpretador que a implementa. O livro começa com uma linguagem minúscula, LET, e a cada capítulo acrescenta uma ideia nova - funções (PROC), recursão (LETREC), atribuição (EXPLICIT-REFS, IMPLICIT-REFS), tipos (CHECKED, INFERRED), objetos (CLASSES) -, sempre como uma modificação do interpretador anterior.

LET tem apenas seis construções. A gramática, como está no livro:

```
Program    ::= Expression

Expression ::= Number
             | -(Expression , Expression)
             | zero?(Expression)
             | if Expression then Expression else Expression
             | Identifier
             | let Identifier = Expression in Expression
```

E só. Não há `+` (soma é subtração de negativo), não há funções, não há laços. Há números, uma subtração, um teste de zero, um condicional, variáveis e `let`. Alguns programas:

```
-(-(x, 3), -(v, i))

let x = 5 in -(x, 3)

let x = 33
in let y = 22
   in if zero?(-(x, 11)) then -(y, 2) else -(y, 4)

let z = 5
in let x = 3
   in let y = -(x, 1)     % aqui x = 3
      in let x = 4
         in -(z, -(x, y)) % aqui x = 4
```

O primeiro usa `x`, `v` e `i` sem declará-los: o livro define um AMBIENTE INICIAL em que `i` vale 1, `v` vale 5 e `x` vale 10. O `%` começa um comentário que vai até o fim da linha.

### O PLANO

Tudo o que vamos escrever cabe num desenho só:

```
                    texto do programa
                           |
                           |  scan          Tema 88 - análise léxica
                           v
                    lista de tokens
                           |
                           |  parseExp      Tema 89 - análise sintática
                           v
                 árvore de sintaxe (exp)    Tema 82
                           |
          +----------------+-----------------+
          |                |                 |
          | valueOf        | racketDe        | forthDe
          | Tema 85        | Tema 92         | Tema 93
          v                v                 v
        valor         texto Racket       texto Forth
                           |                 |
                         racket            gforth
                           |                 |
                           v                 v
                         valor             valor
```

A metade de cima - do texto à árvore - é a análise sintática da aula passada. A metade de baixo tem três saídas para a MESMA árvore: calcular o valor (interpretar) ou traduzir para outra linguagem (compilar). Curiosamente, vamos começar pelo meio: primeiro a árvore e o interpretador, que são o coração do livro; o texto e os tokens ficam para depois.

### CUIDADO - O LIVRO USA SCHEME; NÓS USAMOS SML

O código do EOPL é escrito em Scheme (roda em Racket, com `#lang eopl`). Para representar árvores, o livro precisa de uma ferramenta própria, `define-datatype`, e para percorrê-las, outra, `cases`. As duas são, confessadamente, uma imitação do `datatype` e do casamento de padrões de ML. Em SML elas já vêm de fábrica - por isso o código daqui é mais curto que o do livro. Os nomes das funções (`value-of`, `apply-env`, `extend-env`) são os do livro, com o hífen trocado por maiúscula, como no tutorial de acumuladores.

### EXERCÍCIOS

- 81.1 Calcule de cabeça o valor de cada um dos quatro programas acima. Guarde as respostas: o Tema 90 vai conferir.
- 81.2 Como você escreveria `x + y` em LET, sem `+`?
- 81.3 Escreva um programa LET que devolve 1 se `x` for zero e 0 caso contrário.

## TEMA 82 - A SINTAXE ABSTRATA: UM datatype

Cada linha da gramática do Tema 81 vira um construtor:

```
datatype exp =
    ConstExp of int                    (* 5                        *)
  | DiffExp  of exp * exp              (* -(e1, e2)                *)
  | ZeroExp  of exp                    (* zero?(e)                 *)
  | IfExp    of exp * exp * exp        (* if e1 then e2 else e3    *)
  | VarExp   of string                 (* x                        *)
  | LetExp   of string * exp * exp;    (* let x = e1 in e2         *)

datatype program = AProgram of exp;
```

Os nomes dos construtores são os do livro (`const-exp`, `diff-exp`, ...). Compare a gramática com o `datatype` linha por linha: onde a gramática diz `Expression`, o construtor tem um `exp`; onde diz `Identifier`, tem um `string`; onde diz `Number`, tem um `int`. O que SUMIU foram os pedaços de texto que só servem para separar e marcar - os parênteses, a vírgula, as palavras `if`, `then`, `else`, `let`, `=`, `in`. Esses pedaços pertencem à SINTAXE CONCRETA, o texto que o programador digita. O `datatype` é a SINTAXE ABSTRATA: só a estrutura, sem a pontuação.

Como no `Lizt` do Tema 56, o `datatype` é RECURSIVO: `exp` aparece dentro de `exp`. Por isso um programa é uma árvore. `let x = 5 in -(x, 3)` fica assim:

```
val exemplo1 : program =
    AProgram (LetExp ("x", ConstExp 5, DiffExp (VarExp "x", ConstExp 3)));
```

```
          LetExp
        /   |    \
     "x"  ConstExp  DiffExp
             |      /     \
             5  VarExp  ConstExp
                  |        |
                 "x"       3
```

É a árvore de sintaxe abstrata - a AST - da aula passada, agora com um tipo que o compilador de SML confere. `DiffExp (VarExp "x")`, com um filho só, não compila; `LetExp (5, ...)`, com um número no lugar do nome, também não. Uma árvore malformada nem chega a existir.

### EXERCÍCIOS

- 82.1 Escreva à mão, como `exemplo1`, a árvore de `-(-(x, 3), -(v, i))`. Desenhe-a também.
- 82.2 Escreva a árvore de `if zero?(x) then 1 else 2`.
- 82.3 Quantos construtores `LetExp` tem a árvore do quarto programa do Tema 81? E quantos `VarExp`?
- 82.4 Por que `program` é um `datatype` separado, com um construtor só, em vez de usar `exp` direto? (Pense nas linguagens dos próximos capítulos do livro, em que um programa pode ter mais coisas do que uma expressão.)

## TEMA 83 - OS VALORES DA LINGUAGEM

Antes de calcular, é preciso decidir o que um cálculo pode PRODUZIR. Em LET, uma expressão pode dar um número (`-(x, 3)`) ou um booleano (`zero?(x)`). O livro chama isso de VALORES EXPRESSOS (expressed values), e o tipo é mais um `datatype`:

```
datatype expval = NumVal of int | BoolVal of bool;
```

Repare que `expval` é uma SOMA de dois tipos (Tema 53): um valor de LET é OU um número OU um booleano, e carrega a etiqueta que diz qual dos dois. Essa etiqueta é o que permite ao interpretador descobrir, durante a execução, que tipo de valor tem nas mãos.

O livro também fala em VALORES DENOTADOS (denoted values): os que uma variável pode guardar. Em LET, os dois conjuntos coincidem - toda variável guarda um número ou um booleano -, então não precisamos de um tipo separado. Nas linguagens dos capítulos seguintes eles se separam, e é por isso que o livro faz a distinção desde já.

Para tirar o número de dentro de um `NumVal`, o livro define `expval->num`, e para o booleano, `expval->bool`. E se o valor tiver a etiqueta errada? Não há resposta certa, então a função levanta uma exceção:

```
exception ErroDeTipo of string;

fun expvalParaNum (NumVal n : expval) : int = n
  | expvalParaNum (BoolVal _ : expval) : int =
        raise ErroDeTipo "esperava um numero, veio um booleano";

fun expvalParaBool (BoolVal b : expval) : bool = b
  | expvalParaBool (NumVal _ : expval) : bool =
        raise ErroDeTipo "esperava um booleano, veio um numero";
```

`exception ErroDeTipo of string` declara uma exceção que CARREGA uma string - a mensagem. É o mesmo mecanismo do `raise Empty` do Tema 57, só que com uma exceção nossa.

### EXERCÍCIOS

- 83.1 Qual é o tipo de `expvalParaNum`? Responda antes de perguntar ao REPL.
- 83.2 Chame `expvalParaNum (BoolVal true)` e veja o que o REPL mostra.
- 83.3 Se LET tivesse strings, o que mudaria em `expval`? E se tivesse listas (exercício 3.9 do livro)?

## TEMA 84 - AMBIENTES: QUEM GUARDA O VALOR DE CADA NOME

Para calcular `-(x, 3)`, o interpretador precisa saber quanto vale `x`. Quem sabe isso é o AMBIENTE: uma tabela que associa nomes a valores. O livro especifica o ambiente por três operações, e deixa a representação em aberto:

```
emptyEnv                  o ambiente vazio
extendEnv (x, v, env)     um ambiente novo: env, mais x valendo v
applyEnv (env, x)         quanto vale x em env?
```

A representação mais simples é a do exercício 67.3: uma lista de pares (nome, valor).

```
type env = (string * expval) list;

exception VariavelLivre of string;

val emptyEnv : env = [];

fun extendEnv (x : string, v : expval, e : env) : env = (x, v) :: e;

fun applyEnv ([] : env, x : string) : expval = raise VariavelLivre x
  | applyEnv ((y, v) :: resto : env, x : string) : expval =
        if x = y then v else applyEnv (resto, x);
```

`type env = ...` não cria um tipo novo: só dá um NOME curto a um tipo que já existe, como um apelido. E `applyEnv` é uma velha conhecida - é o `pertence?` do Tema 29, só que devolvendo o valor achado em vez de `#t`. Recursão de cauda, como o Tema 72 mostrou.

O ambiente inicial do livro:

```
val initEnv : env =
    extendEnv ("i", NumVal 1,
      extendEnv ("v", NumVal 5,
        extendEnv ("x", NumVal 10, emptyEnv)));
```

```
val initEnv = [("i",NumVal 1),("v",NumVal 5),("x",NumVal 10)] : env
```

### O MAIS NOVO NA FRENTE

`extendEnv` põe o par novo na FRENTE da lista com `::`, e `applyEnv` procura da frente para trás. A consequência é importante: se um nome aparecer duas vezes, vale o MAIS RECENTE.

```
extendEnv ("x", NumVal 3, initEnv);
applyEnv (extendEnv ("x", NumVal 3, initEnv), "x");
```

```
val it = [("x",NumVal 3),("i",NumVal 1),("v",NumVal 5),("x",NumVal 10)] : env
val it = NumVal 3 : expval
```

O `x` que vale 10 continua lá, no fundo da lista - escondido, não apagado. É exatamente o que um `let` interno faz com um nome que já existia fora dele, e é o assunto do Tema 86.

### CUIDADO - applyEnv SÓ FALHA QUANDO O NOME NÃO EXISTE EM LUGAR NENHUM

`applyEnv (initEnv, "w")` levanta `VariavelLivre`: uma VARIÁVEL LIVRE é um nome usado sem ter sido declarado. Em LET, esse erro só aparece quando o programa RODA, e só se a execução passar por ali. `if zero?(0) then 1 else w` devolve 1 sem reclamar, porque o ramo do `else` nunca é avaliado.

### EXERCÍCIOS

- 84.1 Monte, com `extendEnv`, um ambiente em que `a` vale 1 e `b` vale `true`, e consulte os dois com `applyEnv`.
- 84.2 O livro também representa ambientes como FUNÇÕES: o ambiente é uma função que recebe um nome e devolve o valor. Escreva `emptyEnvF`, `extendEnvF` e `applyEnvF` assim, com tipo `type envF = string -> expval`. Dica: `extendEnvF (x, v, e)` devolve `fn y => if y = x then v else e y`.
- 84.3 Releia `applyEnv`. Ela é uma função de busca. Escreva-a com `List.find` em vez de recursão.

## TEMA 85 - O INTERPRETADOR: valueOf

O livro especifica o significado de cada construção por uma EQUAÇÃO. Escritas com a nossa grafia, e com ρ (rô) para o ambiente, como no livro:

```
valueOf (ConstExp n, ρ)          = NumVal n
valueOf (VarExp x, ρ)            = applyEnv (ρ, x)
valueOf (DiffExp (e1, e2), ρ)    = NumVal (n1 - n2)
                                   onde n1 e n2 são os números de
                                   valueOf (e1, ρ) e valueOf (e2, ρ)
valueOf (ZeroExp e, ρ)           = BoolVal (n = 0)
                                   onde n é o número de valueOf (e, ρ)
valueOf (IfExp (e1, e2, e3), ρ)  = valueOf (e2, ρ), se valueOf (e1, ρ) for verdadeiro
                                   valueOf (e3, ρ), se for falso
valueOf (LetExp (x, e1, e2), ρ)  = valueOf (e2, ρ'), onde
                                   ρ' é ρ estendido com x valendo valueOf (e1, ρ)
```

Essas seis linhas SÃO a semântica de LET - o "nível semântico" da Aula 01. O interpretador é a tradução direta delas, uma cláusula por construtor, como manda o Tema 57:

```
fun valueOf (ConstExp n : exp, env : env) : expval = NumVal n
  | valueOf (VarExp x : exp, env : env) : expval = applyEnv (env, x)
  | valueOf (DiffExp (e1, e2) : exp, env : env) : expval =
        let
            val n1 : int = expvalParaNum (valueOf (e1, env))
            val n2 : int = expvalParaNum (valueOf (e2, env))
        in
            NumVal (n1 - n2)
        end
  | valueOf (ZeroExp e : exp, env : env) : expval =
        BoolVal (expvalParaNum (valueOf (e, env)) = 0)
  | valueOf (IfExp (e1, e2, e3) : exp, env : env) : expval =
        if expvalParaBool (valueOf (e1, env))
        then valueOf (e2, env)
        else valueOf (e3, env)
  | valueOf (LetExp (x, e1, corpo) : exp, env : env) : expval =
        valueOf (corpo, extendEnv (x, valueOf (e1, env), env));

fun valueOfProgram (AProgram e : program) : expval = valueOf (e, initEnv);
```

```
valueOfProgram exemplo1;
```

```
val it = NumVal 2 : expval
```

Leia cada cláusula com o pulo do gato do Tema 19 - agora sobre uma ÁRVORE em vez de uma lista. Em `DiffExp (e1, e2)`, confie que `valueOf (e1, env)` já devolve o valor certo da subárvore da esquerda, e `valueOf (e2, env)` o da direita. Seu trabalho é só combinar os dois. Uma lista tem uma cauda; uma `DiffExp` tem duas "caudas", e por isso duas chamadas recursivas. A ideia é a mesma.

Três detalhes merecem atenção:

1. **`DiffExp` e `ZeroExp` usam `expvalParaNum`.** Os filhos devolvem `expval`, mas a subtração de SML só trabalha com `int`. É aqui que a etiqueta de `NumVal` é conferida.
2. **`IfExp` avalia só um dos ramos.** O `if` de SML é que decide qual dos dois `valueOf` acontece. Se LET avaliasse os dois ramos, `if zero?(0) then 1 else w` (CUIDADO do Tema 84) quebraria.
3. **`LetExp` é a única cláusula que MUDA o ambiente.** O valor de `e1` é calculado no ambiente de fora, e o corpo é calculado num ambiente estendido. Nenhuma outra construção acrescenta nomes.

### CUIDADO - O AMBIENTE DO let NÃO VAZA PARA FORA DELE

`extendEnv` não modifica `env`: cria uma lista NOVA, com um par a mais na frente, e a velha continua intacta (Tema 46 - em SML, nada muda de valor). Então, quando `valueOf` termina o corpo do `let` e volta, quem estava fora continua vendo o ambiente antigo. É isso que garante que `x` só existe DENTRO do `let x = ... in ...`. Ninguém precisou escrever código para "apagar" a variável no fim: ela simplesmente não está no ambiente de quem chamou.

### EXERCÍCIOS

- 85.1 Escreva a árvore de `-(-(x, 3), -(v, i))` (você fez no 82.1) e rode com `valueOfProgram`. O livro diz que dá 3.
- 85.2 Quantas chamadas de `valueOf` acontecem para calcular `-(-(x, 3), -(v, i))`? Desenhe a árvore de chamadas.
- 85.3 Troque, só por teste, a cláusula de `IfExp` por uma que calcula os dois ramos antes de escolher (dois `val` no `let`). Construa um programa que funcionava e passa a quebrar.
- 85.4 Em `LetExp`, o que aconteceria se `e1` fosse calculado no ambiente JÁ estendido? (Dica: com o que `x` seria estendido?) Isso tem a ver com recursão - é o assunto do LETREC, no capítulo seguinte do livro.

## TEMA 86 - RASTREANDO UMA EXECUÇÃO: ESCOPO E SOMBREAMENTO

O quarto programa do Tema 81 é o exemplo do livro sobre escopo:

```
let z = 5
in let x = 3
   in let y = -(x, 1)     % aqui x = 3
      in let x = 4
         in -(z, -(x, y)) % aqui x = 4
```

Siga o ambiente a cada `let`, sempre com o mais novo na frente:

```
início        [i=1, v=5, x=10]
let z = 5     [z=5, i=1, v=5, x=10]
let x = 3     [x=3, z=5, i=1, v=5, x=10]
let y = -(x, 1)
              -(x, 1) é calculado AQUI, onde x é 3: y vale 2
              [y=2, x=3, z=5, i=1, v=5, x=10]
let x = 4     [x=4, y=2, x=3, z=5, i=1, v=5, x=10]
-(z, -(x, y)) z=5, x=4 (o primeiro x da lista), y=2
              5 - (4 - 2) = 3
```

Duas coisas aconteceram com `x`, e as duas são a regra do ESCOPO LÉXICO (ou estático):

1. **Sombreamento.** O `let x = 4` não apaga o `x = 3`, nem o `x = 10` do ambiente inicial: só os esconde, porque fica na frente. Em inglês, shadowing - o `x` interno faz sombra sobre os externos.
2. **O valor de y foi fixado quando y nasceu.** `y` foi calculado como `-(x, 1)` quando `x` ainda era 3, e vale 2 para sempre. A mudança posterior de `x` não afeta `y`. Um `let` liga um nome a um VALOR, não a uma fórmula.

Para olhar o ambiente na hora em que cada coisa é calculada, pense de dentro para fora no texto: um nome se refere ao `let` mais próximo, ENVOLVENDO o ponto em que ele aparece. É por isso que se chama léxico: dá para descobrir só lendo o texto, sem rodar.

### EXERCÍCIOS

- 86.1 Faça a tabela de ambientes para `let x = 7 in let y = 2 in let y = let x = -(x, 1) in -(x, y) in -(-(x, 8), y)`. (Resposta: -5.)
- 86.2 No programa do exemplo, troque o último `x` por `v`. Qual é o resultado agora?
- 86.3 Escreva um programa LET em que o mesmo nome aparece com TRÊS valores diferentes em três lugares, e preveja o resultado.

## TEMA 87 - ERROS: UMA LINGUAGEM DINÂMICA ESCRITA NUMA ESTÁTICA

Tente:

```
valueOf (IfExp (ConstExp 5, ConstExp 1, ConstExp 2), initEnv);
```

```
uncaught exception ErroDeTipo
  raised at: let.sml:54.15-54.64
```

`if 5 then 1 else 2` não faz sentido - 5 não é verdadeiro nem falso -, e o interpretador só descobre isso RODANDO, quando `expvalParaBool` encontra um `NumVal`. O REPL do SML/NJ mostra só o nome da exceção, sem a mensagem que ela carrega; no Tema 90 vamos tratar isso.

Repare na situação curiosa. O interpretador está escrito em SML, uma linguagem ESTATICAMENTE tipada. Mas a linguagem que ele implementa, LET, é DINAMICAMENTE tipada: os erros de tipo de um programa LET só aparecem quando ele roda, exatamente como em Racket (Tema 66). Não há contradição. O sistema de tipos de SML garante que o INTERPRETADOR está bem formado - que `valueOf` sempre devolve um `expval`, que toda árvore tem os filhos certos. Ele não sabe nada sobre os programas LET que o interpretador vai receber: para SML, `IfExp (ConstExp 5, ...)` é uma árvore perfeitamente válida.

Para pegar esse erro ANTES de rodar, seria preciso um verificador de tipos para LET - um programa que percorre a árvore e confere, sem calcular nada, que a condição de todo `if` é booleana. O livro faz isso no capítulo 7, com a linguagem CHECKED. É, em miniatura, o que o compilador de SML faz com o seu código.

```
linguagem         escrita em    tipos verificados    pelo quê
----------------  ------------  -------------------  -------------------------
o interpretador   SML           antes de rodar       o compilador de SML
um programa LET   LET           durante a execução   expvalParaNum/expvalParaBool
```

### EXERCÍCIOS

- 87.1 Escreva três programas LET que causam ErroDeTipo, cada um por um caminho diferente (em `-`, em `zero?`, em `if`).
- 87.2 Escreva um programa LET com um erro de tipo que NUNCA é detectado, porque está num ramo que não roda.
- 87.3 Esboce, em português, as regras de um verificador de tipos para LET: para cada construção, qual é o tipo do resultado, e o que precisa ser conferido nos filhos?

## TEMA 88 - DO TEXTO AOS TOKENS: A ANÁLISE LÉXICA

Até aqui, os programas foram escritos como árvores, à mão. Agora vem a metade de cima do desenho do Tema 81: transformar TEXTO em árvore. A primeira etapa é a ANÁLISE LÉXICA - o nível léxico da Aula 01: quebrar o texto em palavras, os TOKENS.

```
datatype token =
    NUM of int | ID of string
  | MENOS | ABRE | FECHA | VIRGULA | IGUAL
  | ZERO | IF | THEN | ELSE | LET | IN;
```

Cada pedaço de pontuação e cada palavra reservada vira um construtor sem dados; números e nomes carregam o que leram. Espaços e comentários desaparecem. O objetivo:

```
"let x = 5 in -(x, 3)"
   =>  [LET, ID "x", IGUAL, NUM 5, IN, MENOS, ABRE, ID "x", VIRGULA, NUM 3, FECHA]
```

### LER ENQUANTO DER: UM ACUMULADOR

Números e nomes têm comprimento variável: `123` são três caracteres, um token. A ferramenta para isso é uma função que lê caracteres enquanto uma condição valer, e devolve o que leu E o que sobrou:

```
fun lerEnquanto (p : char -> bool, [] : char list, acc : char list)
        : string * char list =
        (implode (rev acc), [])
  | lerEnquanto (p : char -> bool, c :: cs : char list, acc : char list)
        : string * char list =
        if p c then lerEnquanto (p, cs, c :: acc)
        else (implode (rev acc), c :: cs);
```

```
lerEnquanto (Char.isDigit, explode "123abc", []);
```

```
val it = ("123",[#"a",#"b",#"c"]) : string * char list
```

É uma função do tutorial de acumuladores, sem tirar nem pôr: `acc` significa "os caracteres já lidos, de trás para frente", começa vazio, e por isso o `rev` no fim (Tema 74). `explode` transforma uma string em lista de caracteres, `implode` faz o contrário, e `#"a"` é como SML escreve o CARACTERE a (diferente da string `"a"`).

### O SCANNER

O scanner olha o primeiro caractere e decide. Caracteres de pontuação se resolvem com um padrão cada - um literal de caractere é um padrão, como o `0` do Tema 75:

```
fun scan ([] : char list) : token list = []
  | scan (#"(" :: cs : char list) : token list = ABRE :: scan cs
  | scan (#")" :: cs : char list) : token list = FECHA :: scan cs
  | scan (#"," :: cs : char list) : token list = VIRGULA :: scan cs
  | scan (#"=" :: cs : char list) : token list = IGUAL :: scan cs
  | scan (#"%" :: cs : char list) : token list =            (* comentario *)
        scan (#2 (lerEnquanto (fn c => c <> #"\n", cs, [])))
  | scan (#"-" :: d :: cs : char list) : token list =
        if Char.isDigit d
        then let val (s, resto) = lerEnquanto (Char.isDigit, d :: cs, [])
             in NUM (~ (numero s)) :: scan resto end
        else MENOS :: scan (d :: cs)
  | scan (c :: cs : char list) : token list =
        if Char.isSpace c then scan cs
        else if Char.isDigit c then
            let val (s, resto) = lerEnquanto (Char.isDigit, c :: cs, [])
            in NUM (numero s) :: scan resto end
        else if Char.isAlpha c then
            let val (s, resto) = lerEnquanto (ehDoNome, c :: cs, [])
            in palavra s :: scan resto end
        else raise ErroLexico ("caractere inesperado: " ^ str c);
```

As funções auxiliares (`numero`, `ehDoNome`, `palavra`) estão em let.sml. A mais interessante é `palavra`: o scanner lê `let`, `if` ou `zero?` exatamente como leria `x` ou `abc` - como um NOME -, e só depois `palavra` confere se o nome é reservado. É assim que quase todo scanner trata palavras reservadas.

Dois casos merecem atenção:

1. **`%`** descarta tudo até o fim da linha. `#2` pega o segundo componente de uma tupla - o resto do texto -, e o comentário lido é jogado fora.
2. **`-`** é ambíguo: em `-(x, 3)` é a subtração, em `-5` é parte de um número negativo. A decisão exige olhar UM caractere adiante - o padrão `#"-" :: d :: cs` faz exatamente isso. Se `d` for dígito, é número negativo; senão, é o token `MENOS`, e `d` volta para a lista sem ter sido consumido.

```
scan (explode "zero?(-(x,-5))");
```

```
val it = [ZERO,ABRE,MENOS,ABRE,ID "x",VIRGULA,NUM ~5,FECHA,FECHA] : token list
```

### CUIDADO - O SCANNER NÃO ENTENDE NADA

`scan (explode "in in in let")` funciona perfeitamente e devolve `[IN, IN, IN, LET]`. O scanner só reconhece palavras; não sabe se elas formam uma frase. "Dorme a ante 98 oi tenda claramente foi" (Aula 01) passa no nível léxico. Quem rejeita frases malformadas é a próxima etapa.

### EXERCÍCIOS

- 88.1 Rode `scan` sobre os quatro programas do Tema 81. Quantos tokens tem cada um?
- 88.2 O que `scan (explode "x-1")` devolve? E `scan (explode "-(x,-1)")`? Explique os dois.
- 88.3 `scan` NÃO é recursiva de cauda (por quê?). Reescreva-a com um acumulador de tokens. Você vai precisar de um `rev` no fim?
- 88.4 Acrescente o token `MAIS` para o caractere `+`, preparando o exercício 95.2.

## TEMA 89 - DOS TOKENS À ÁRVORE: A ANÁLISE SINTÁTICA

A gramática de LET tem uma propriedade muito conveniente: olhando só o PRIMEIRO token, dá para saber qual regra se aplica. `NUM` é constante; `ID` é variável; `MENOS` é subtração; `ZERO` é teste de zero; `IF` é condicional; `LET` é let. Nenhuma regra começa igual a outra. Gramáticas assim se chamam LL(1), e para elas existe um método de análise que cabe numa função só: a ANÁLISE DESCENDENTE RECURSIVA.

A ideia: uma função para cada não-terminal da gramática (aqui só há um, `Expression`). Ela recebe a lista de tokens, consome do início o pedaço que forma UMA expressão, e devolve DUAS coisas: a árvore reconhecida e os tokens que sobraram.

```
parseExp : token list -> exp * token list
```

```
parseExp (scan (explode "-(x, 3) sobra"));
```

```
val it = (DiffExp (VarExp "x",ConstExp 3),[ID "sobra"]) : exp * token list
```

Por que devolver o que sobrou? Porque em `-(e1, e2)`, quem analisa `e1` não sabe onde ela termina - só ela mesma sabe. Então ela consome o que é seu e devolve o resto, de onde a análise continua: vírgula, `e2`, fecha-parênteses. Cada etapa passa o resto adiante, como um bastão numa corrida de revezamento.

Para os tokens de pontuação, que TÊM que estar ali, uma função auxiliar consome ou reclama:

```
fun esperar (t : token, [] : token list) : token list =
        raise ErroSintatico ("esperava " ^ entreAspas t ^ ", o programa acabou")
  | esperar (t : token, t' :: resto : token list) : token list =
        if t = t' then resto
        else raise ErroSintatico ("esperava " ^ entreAspas t ^
                                  ", veio " ^ entreAspas t');
```

E o analisador, uma cláusula por regra da gramática, decidida pelo primeiro token:

```
fun parseExp (NUM n :: resto : token list) : exp * token list = (ConstExp n, resto)
  | parseExp (ID x :: resto) = (VarExp x, resto)
  | parseExp (MENOS :: r0) =                        (* -(e1, e2) *)
        let
            val r1 = esperar (ABRE, r0)
            val (e1, r2) = parseExp r1
            val r3 = esperar (VIRGULA, r2)
            val (e2, r4) = parseExp r3
            val r5 = esperar (FECHA, r4)
        in
            (DiffExp (e1, e2), r5)
        end
  | parseExp (ZERO :: r0) = ...                     (* zero?(e) *)
  | parseExp (IF :: r0) = ...                       (* if e1 then e2 else e3 *)
  | parseExp (LET :: ID x :: r0) =                  (* let x = e1 in e2 *)
        let
            val r1 = esperar (IGUAL, r0)
            val (e1, r2) = parseExp r1
            val r3 = esperar (IN, r2)
            val (e2, r4) = parseExp r3
        in
            (LetExp (x, e1, e2), r4)
        end
  | parseExp ... (as cláusulas de erro)
```

(As cláusulas de `ZERO` e `IF`, no mesmo molde, e as de erro estão em let.sml.)

Leia a cláusula de `MENOS` ao lado da regra da gramática:

```
-(   Expression   ,   Expression   )
 |       |        |       |        |
r1      e1, r2    r3     e2, r4    r5
```

Cada símbolo da regra vira uma linha do `let`: um terminal vira um `esperar`, um não-terminal vira uma chamada recursiva a `parseExp`. `r0`, `r1`, ..., `r5` são os restos sucessivos da lista - o bastão sendo passado. A estrutura da função copia a estrutura da regra, do mesmo jeito que, no Tema 57, a estrutura da função copiava a do `datatype`.

O padrão `LET :: ID x :: r0` confere DOIS tokens de uma vez: que vem `let` e que depois dele vem um nome.

### CUIDADO - UM TOKEN NÃO PODE SER USADO DUAS VEZES

Na cláusula de `MENOS`, cada `esperar` e cada `parseExp` recebe o resto devolvido pela etapa ANTERIOR. Se você passar `r1` em vez de `r3` para a segunda `parseExp`, ela vai reler a primeira expressão. SML não acusa esse erro (`r1` e `r3` têm o mesmo tipo), e o resultado é uma árvore errada ou um erro sintático estranho. A numeração dos restos é o que torna esse erro visível para quem lê.

### EXERCÍCIOS

- 89.1 Escreva, no papel, a sequência de chamadas a `parseExp` e `esperar` para `-(x, 3)`, com o valor de `r0` a `r5`.
- 89.2 Por que a gramática não poderia ter, ao mesmo tempo, `Expression ::= Identifier` e `Expression ::= Identifier ( Expression )`? O que `parseExp` precisaria fazer de diferente?
- 89.3 E se a subtração fosse escrita `e1 - e2`, infixa, em vez de `-(e1, e2)`? Que problema isso causaria para "decidir pelo primeiro token"?

## TEMA 90 - JUNTANDO TUDO

A frente do desenho está completa. `ler` vai do texto à árvore, e confere que nada sobrou:

```
fun ler (texto : string) : program =
    case parseExp (scan (explode texto)) of
        (e, []) => AProgram e
      | (_, t :: _) => raise ErroSintatico ("sobrou texto a partir de " ^ entreAspas t);
```

```
ler "let z = 5 in let x = 3 in let y = -(x, 1) in let x = 4 in -(z, -(x, y))";
```

```
val it =
  AProgram
    (LetExp
       ("z",ConstExp 5,
        LetExp
          ("x",ConstExp 3,
           LetExp
             ("y",DiffExp (VarExp "x",ConstExp 1),
              LetExp
                ("x",ConstExp 4,
                 DiffExp (VarExp "z",DiffExp (VarExp "x",VarExp "y")))))))
  : program
```

A indentação do REPL desenha a árvore de lado. (A primeira linha de let.sml, `Control.Print.printDepth := 20`, é o que faz o REPL mostrar a árvore inteira, em vez de abreviar as partes fundas com `#`.)

E `rodar` vai do texto ao valor - e transforma as exceções em mensagens, já que o REPL só mostraria o nome delas (Tema 87):

```
fun rodar (texto : string) : string =
    mostrar (valueOfProgram (ler texto))
    handle ErroLexico m    => "erro lexico: " ^ m
         | ErroSintatico m => "erro sintatico: " ^ m
         | VariavelLivre x => "erro: variavel livre " ^ x
         | ErroDeTipo m    => "erro de tipo: " ^ m;
```

`handle` é o `try/catch` de SML: se a expressão da esquerda levantar uma das exceções listadas, o valor passa a ser o do ramo correspondente, e o `m` casa com a mensagem que a exceção carrega. `mostrar` transforma um `expval` em texto (está em let.sml).

```
rodar "-(-(x, 3), -(v, i))";
rodar "let x = 7 in let y = 2 in let y = let x = -(x,1) in -(x,y) in -(-(x,8), y)";
rodar "-(x, y)";
rodar "if 5 then 1 else 2";
rodar "-(x 3)";
rodar "x + 1";
```

```
val it = "3" : string
val it = "-5" : string
val it = "erro: variavel livre y" : string
val it = "erro de tipo: esperava um booleano, veio um numero" : string
val it = "erro sintatico: esperava ',', veio '3'" : string
val it = "erro lexico: caractere inesperado: +" : string
```

Repare que cada erro vem de uma etapa diferente do desenho do Tema 81, e a mensagem diz qual. `+` não é uma palavra de LET (léxico). `-(x 3)` tem palavras válidas numa ordem inválida (sintático). `-(x, y)` está bem escrito, mas `y` não existe (semântico, durante a execução). São os três níveis da Aula 01, cada um com o seu tipo de erro.

### EXERCÍCIOS

- 90.1 Rode os quatro programas do Tema 81 e confira suas respostas do 81.1.
- 90.2 Para cada nível (léxico, sintático, semântico), escreva dois programas LET errados e confira que `rodar` aponta o nível certo.
- 90.3 `rodar "let x = 5 in"` dá qual erro? E `rodar "5 5"`? Por que são mensagens diferentes?

## TEMA 91 - INTERPRETAR OU COMPILAR?

`valueOf` recebe uma árvore e devolve um VALOR. Ela mesma faz as contas: para executar um programa LET, o interpretador precisa estar rodando. Isso é INTERPRETAR.

A alternativa é TRADUZIR: receber a árvore e devolver um OUTRO PROGRAMA, numa outra linguagem, que calcula a mesma coisa. Quem executa esse programa é a implementação da outra linguagem. Isso é COMPILAR, e a outra linguagem se chama linguagem-ALVO.

```
interpretador:   programa  ---->  [ interpretador ]  ---->  valor

compilador:      programa  ---->  [ compilador ]  ---->  programa-alvo
                                                               |
                                                               v
                                              [ implementação do alvo ]  ---->  valor
```

O livro mostra os dois esquemas na seção 3.1 e, no capítulo 3, segue pelo caminho do interpretador. Vamos agora pelo outro caminho, duas vezes, com dois alvos bem diferentes:

- **Racket**, uma linguagem de alto nível que já tem quase tudo o que LET tem: números, subtração, `zero?`, `if`, `let`. A tradução vai ser quase palavra por palavra.
- **Forth**, uma linguagem de pilha, sem variáveis com nome, sem expressões aninhadas, sem tipos. Tudo o que LET tem e Forth não tem vai precisar ser simulado pelo compilador.

O compilador NÃO calcula o valor do programa. Ele não chama `valueOf`, não tem ambiente com valores, não sabe quanto vale `x`. Ele só sabe ESCREVER código que, quando rodar, vai calcular. Guarde essa distinção: ela vai aparecer de novo quando os compiladores tiverem que lidar com nomes.

### EXERCÍCIOS

- 91.1 Python, Java, C, JavaScript: para cada uma, descubra se a implementação mais usada é um interpretador, um compilador, ou uma mistura. (Dica: procure "bytecode" e "JIT".)
- 91.2 Um compilador que traduz LET para LET (por exemplo, trocando `-(x, 0)` por `x`) faz sentido? Para que serviria?

## TEMA 92 - O COMPILADOR PARA RACKET

Cada construção de LET tem uma equivalente direta em Racket:

```
LET                          Racket
---------------------------  ------------------------------
5                            5
x                            x
-(e1, e2)                    (- e1 e2)
zero?(e)                     (zero? e)
if e1 then e2 else e3        (if e1 e2 e3)
let x = e1 in e2             (let ([x e1]) e2)
```

O compilador é essa tabela, escrita como função - de novo uma cláusula por construtor, mas agora devolvendo TEXTO em vez de valor:

```
fun racketDe (ConstExp n : exp) : string = intParaTexto n
  | racketDe (VarExp x) = x
  | racketDe (DiffExp (e1, e2)) = "(- " ^ racketDe e1 ^ " " ^ racketDe e2 ^ ")"
  | racketDe (ZeroExp e) = "(zero? " ^ racketDe e ^ ")"
  | racketDe (IfExp (e1, e2, e3)) =
        "(if " ^ racketDe e1 ^ " " ^ racketDe e2 ^ " " ^ racketDe e3 ^ ")"
  | racketDe (LetExp (x, e1, corpo)) =
        "(let ([" ^ x ^ " " ^ racketDe e1 ^ "]) " ^ racketDe corpo ^ ")";
```

`intParaTexto` escreve os negativos como `-3`, e não como `~3` à moda de SML. O ambiente inicial vira um `let` em volta do programa inteiro, e a primeira linha é a de todo arquivo Racket:

```
fun paraRacket (AProgram e : program) : string =
    "#lang racket\n(let ([i 1] [v 5] [x 10])\n  " ^ racketDe e ^ ")\n";
```

```
print (paraRacket (ler "let z = 5 in let x = 3 in let y = -(x, 1) in let x = 4 in -(z, -(x, y))"));
```

```
#lang racket
(let ([i 1] [v 5] [x 10])
  (let ([z 5]) (let ([x 3]) (let ([y (- x 1)]) (let ([x 4]) (- z (- x y)))))))
```

Grave esse texto num arquivo `saida.rkt` (a função `gravar`, em let.sml, faz isso) e rode no terminal:

```
racket saida.rkt
```

```
3
```

O mesmo 3 do interpretador. E sem nenhuma linha de código sobre ambientes: o sombreamento de `x`, o escopo do `let`, tudo isso Racket já faz do mesmo jeito que LET. O compilador ficou curto porque o alvo é parecido com a fonte.

### CUIDADO - "QUASE IGUAL" NÃO É IGUAL

O `if` de Racket aceita QUALQUER valor como condição: tudo que não é `#f` conta como verdadeiro. O de LET exige um booleano. Então:

```
rodar "if 5 then 1 else 2";
```

```
val it = "erro de tipo: esperava um booleano, veio um numero" : string
```

mas o mesmo programa compilado para Racket roda e devolve 1. O compilador MUDOU o significado de um programa. Para a maioria dos programas a diferença não aparece; para este, aparece. Um compilador é CORRETO quando o programa traduzido faz exatamente o que o original faria - inclusive dar erro quando o original daria erro. O nosso não é correto nesse caso. Consertar é o exercício 92.3.

### EXERCÍCIOS

- 92.1 Compile os quatro programas do Tema 81 e rode cada um com `racket`. Confira com `rodar`.
- 92.2 O programa compilado para `-(zero?(0), 1)` dá erro em Racket? Qual? É o mesmo erro do interpretador?
- 92.3 Conserte o `if`: faça `racketDe` gerar um código que confere, durante a execução, se a condição é booleana, e chama `(error "esperava um booleano")` se não for. Dica: `(let ([c e1]) (if (boolean? c) (if c e2 e3) (error ...)))`. Que nome usar no lugar de `c`, para não sombrear uma variável do programa?
- 92.4 Escreva `paraRacket` de modo que o código gerado fique INDENTADO, um `let` por linha.

## TEMA 93 - O COMPILADOR PARA FORTH

Agora o alvo é bem diferente. Forth (Aula 01) não tem expressões aninhadas nem variáveis locais com nome: tem uma PILHA, e palavras que mexem nela. Vamos por partes.

### EXPRESSÕES: NOTAÇÃO POSFIXA

`-(e1, e2)` em Forth é "calcule e1, calcule e2, subtraia": `e1 e2 -`. É a notação posfixa (RPN) do Tema 2. Para compilar uma árvore em notação posfixa, basta visitar os filhos ANTES do pai:

```
-(-(10, 3), 2)       =>      10 3 - 2 -
```

E `zero?(e)` é `e 0=`: `0=` é a palavra de Forth que troca o topo da pilha por "verdadeiro" se ele for zero, e por "falso" senão.

### VARIÁVEIS: ONDE ESTÁ O x?

Este é o problema de verdade. Em Forth não há como dizer "o valor de x". A ideia é esta: quando `let x = e1 in ...` rodar, o valor de `e1` vai ficar NA PILHA, e é lá que ele mora enquanto o corpo é calculado. Para usar `x`, basta saber a que PROFUNDIDADE ele está e copiá-lo para o topo. A palavra que faz isso é `PICK`:

```
n PICK   ( ... xn ... x1 x0 n -- ... xn ... x1 x0 xn )   copia o item de profundidade n
```

`0 PICK` copia o topo (é o mesmo que `DUP`), `1 PICK` o segundo (o mesmo que `OVER`), e assim por diante. Quando o corpo termina, o resultado está no topo e `x` logo abaixo; `NIP` (Tema 4) remove `x` e deixa o resultado.

Como o compilador sabe a profundidade? Ele não roda o programa - mas sabe, para cada ponto do código que gera, o que ESTARÁ na pilha quando aquele ponto rodar. Ele carrega essa descrição numa lista: `SOME x` é a variável `x`, `NONE` é um valor temporário (por exemplo, o resultado de `e1` enquanto `e2` é calculado, em `-(e1, e2)`). A cabeça da lista é o topo.

```
fun profundidade (x : string, [] : string option list, n : int) : int =
        raise VariavelLivre x
  | profundidade (x : string, SOME y :: resto : string option list, n : int) : int =
        if x = y then n else profundidade (x, resto, n + 1)
  | profundidade (x : string, NONE :: resto : string option list, n : int) : int =
        profundidade (x, resto, n + 1);
```

É `applyEnv` (Tema 84) - mas em vez de devolver o VALOR de `x`, que o compilador não conhece, devolve a POSIÇÃO de `x`. E a posição é contada com um acumulador, `n`. A lista `pilha` é o AMBIENTE DO COMPILADOR: os mesmos nomes, na mesma ordem, que o ambiente do interpretador teria naquele ponto, só que sem os valores. O livro chama essa ideia de ENDEREÇO LÉXICO (seção 3.7): trocar cada nome por um número que diz onde encontrá-lo.

O compilador:

```
fun forthDe (ConstExp n : exp, pilha : string option list) : string list =
        [intParaTexto n]
  | forthDe (VarExp x, pilha) =
        [Int.toString (profundidade (x, pilha, 0)), "PICK"]
  | forthDe (DiffExp (e1, e2), pilha) =
        forthDe (e1, pilha) @ forthDe (e2, NONE :: pilha) @ ["-"]
  | forthDe (ZeroExp e, pilha) =
        forthDe (e, pilha) @ ["0="]
  | forthDe (IfExp (e1, e2, e3), pilha) =
        forthDe (e1, pilha) @ ["IF"] @ forthDe (e2, pilha) @
        ["ELSE"] @ forthDe (e3, pilha) @ ["THEN"]
  | forthDe (LetExp (x, e1, corpo), pilha) =
        forthDe (e1, pilha) @ forthDe (corpo, SOME x :: pilha) @ ["NIP"];
```

Leia as duas cláusulas que mexem em `pilha`:

- **`DiffExp`**: enquanto `e2` é calculado, o resultado de `e1` está no topo. Para `e2`, tudo ficou um nível mais fundo - por isso `NONE :: pilha`.
- **`LetExp`**: enquanto o corpo é calculado, o valor de `e1` está no topo, e ele É o `x`. Por isso `SOME x :: pilha`. Compare com `valueOf`: lá era `extendEnv (x, valor, env)`, aqui é `SOME x :: pilha`. A mesma estrutura, sem o valor.

E o ambiente inicial vira três números empilhados no começo - `i` no fundo, `x` no topo:

```
val pilhaInicial : string option list = [SOME "x", SOME "v", SOME "i"];
```

```
forthDe (DiffExp (VarExp "x", ConstExp 3), pilhaInicial);
```

```
val it = ["0","PICK","3","-"] : string list
```

### IF ... ELSE ... THEN, E POR QUE O PROGRAMA VIRA UMA PALAVRA

O condicional de Forth é escrito na ordem posfixa também: primeiro a condição, depois `IF` ramo-verdadeiro `ELSE` ramo-falso `THEN`. (O `THEN` de Forth quer dizer "fim do if" - é uma das esquisitices famosas da linguagem.) Só que `IF` não funciona digitado direto no interpretador:

```
1 0= if 7 else 8 then .
```

```
*OS command line*:-1: Interpreting a compile-only word
```

`IF` só pode ser usado DENTRO de uma definição de palavra, entre `:` e `;` (a parte 2 de Forth, Temas 5 e 8, explica por quê). Por isso o compilador embrulha o programa inteiro numa palavra chamada `programa`, chama essa palavra, imprime o topo com `.` e sai:

```
fun paraForth (AProgram e : program) : string =
    ": programa\n  1 5 10\n  " ^
    String.concatWith " " (forthDe (e, pilhaInicial)) ^
    "\n  NIP NIP NIP ;\nprograma . CR\nbye\n";
```

Os três `NIP` do fim descartam `i`, `v` e `x`, que estão embaixo do resultado.

```
print (paraForth (ler "let z = 5 in let x = 3 in let y = -(x, 1) in let x = 4 in -(z, -(x, y))"));
```

```
: programa
  1 5 10
  5 3 0 PICK 1 - 4 3 PICK 1 PICK 3 PICK - - NIP NIP NIP NIP
  NIP NIP NIP ;
programa . CR
bye
```

Grave num arquivo `saida.fs` e rode:

```
gforth saida.fs
```

```
3
```

Siga a pilha, palavra por palavra (topo à direita; omitimos o `1 5 10` do fundo):

```
palavra    pilha depois             o que é
---------  -----------------------  ------------------------------------
5          5                        z
3          5 3                      x (o primeiro)
0 PICK     5 3 3                    cópia de x, que está no topo
1 -        5 3 2                    -(x, 1): este é o y
4          5 3 2 4                  x (o segundo)
3 PICK     5 3 2 4 5                cópia de z, profundidade 3
1 PICK     5 3 2 4 5 4              cópia do x de dentro, profundidade 1
3 PICK     5 3 2 4 5 4 2            cópia de y, profundidade 3
-          5 3 2 4 5 2              -(x, y)
-          5 3 2 4 3                -(z, -(x, y))
NIP        5 3 2 3                  sai o x de dentro
NIP        5 3 3                    sai o y
NIP        5 3                      sai o x de fora
NIP        3                        sai o z
```

Repare em `1 PICK`, na sétima linha: a profundidade de `x` é 1, e não 0, porque a cópia de `z` acabou de ser empilhada por cima - é o `NONE` que `DiffExp` acrescentou. E repare que o sombreamento funcionou sozinho: `profundidade` devolve o `x` MAIS PRÓXIMO do topo, exatamente como `applyEnv` devolvia o mais próximo da frente da lista.

### CUIDADO - EM FORTH, VERDADEIRO É -1

Forth não tem booleanos. `0=` deixa na pilha o número -1 (todos os bits ligados) para verdadeiro, e 0 para falso, e `IF` trata qualquer número diferente de zero como verdadeiro. Então `zero?(-(x, 10))` compilado para Forth imprime `-1`, e não `true`. E pior: `-(zero?(0), 1)` - um erro de tipo em LET - roda em Forth sem reclamar e devolve -2, porque para Forth o "verdadeiro" é só o número -1. Forth é uma linguagem SEM tipos: não há etiqueta nenhuma para conferir. O compilador para Forth está ainda mais longe de ser correto que o para Racket.

### EXERCÍCIOS

- 93.1 Compile e rode `-(-(x, 3), -(v, i))`. Faça a tabela da pilha, como a de cima.
- 93.2 Compile `let x = 5 in let y = x in -(x, y)` e confira, à mão, a profundidade de cada `PICK`.
- 93.3 `forthDe` usa `@` em todas as cláusulas, e `@` percorre a primeira lista inteira (Tema 73). Reescreva `forthDe` com um ACUMULADOR de palavras, sem nenhum `@`. Dica: gere o código de trás para frente e inverta uma vez no fim - ou percorra a árvore da direita para a esquerda.
- 93.4 Por que `IfExp` passa a MESMA `pilha` para os dois ramos, e não `NONE :: pilha`? (Dica: o que `IF` faz com o topo da pilha?)
- 93.5 Gforth tem variáveis locais: `{ x }` dentro de uma definição tira o topo da pilha e o guarda num nome `x`. Pesquise e escreva um `forthDe` alternativo que use locais em vez de `PICK`. Qual dos dois é mais simples? Qual se parece mais com o interpretador?

## TEMA 94 - OS TRÊS LADO A LADO

A função `comparar`, em let.sml, roda o interpretador, gera os dois arquivos, e chama `racket` e `gforth` pelo terminal (com `OS.Process.system`). É preciso ter os dois instalados - o gforth é o da Aula 01.

```
comparar "let x = 7 in let y = 2 in let y = let x = -(x,1) in -(x,y) in -(-(x,8), y)";
```

```
interpretador: -5
racket.......: -5
gforth.......: -5
```

Para programas corretos, os três concordam. Para os outros:

```
comparar "if 5 then 1 else 2";
```

```
interpretador: erro de tipo: esperava um booleano, veio um numero
racket.......: 1
gforth.......: 1
```

```
comparar "-(zero?(0), 1)";
```

```
interpretador: erro de tipo: esperava um numero, veio um booleano
racket.......: -: contract violation
  expected: number?
  given: #t
  ...
gforth.......: -2
```

O último exemplo resume o tutorial. O mesmo erro foi tratado de três jeitos: o interpretador detecta e explica, porque `expval` carrega etiquetas; Racket detecta, porque os valores de Racket também carregam etiquetas (é uma linguagem dinamicamente tipada); Forth não detecta nada, porque lá tudo é número.

```
                  interpretador           compilador Racket        compilador Forth
----------------  ----------------------  -----------------------  -----------------------
o que produz      um valor                texto em Racket          texto em Forth
variáveis         ambiente: nome->valor   let de Racket            pilha: nome->profundidade
booleanos         BoolVal                 #t / #f                  -1 / 0
erro de tipo      detectado               detectado (outro erro)   não detectado
if com número     erro                    aceita                   aceita
linhas de código  ~20 (valueOf)           ~10 (racketDe)           ~20 (forthDe + profundidade)
```

### EXERCÍCIOS

- 94.1 Rode `comparar` com os quatro programas do Tema 81 e com os seus programas do 87.1.
- 94.2 Encontre um programa LET correto (sem erro no interpretador) em que os três resultados NÃO coincidam. Se não encontrar, explique por que acha que não existe.
- 94.3 O que `comparar` faz se o programa tiver erro sintático? Por quê?

## TEMA 95 - FECHAMENTO E EXERCÍCIOS DO LIVRO

### O QUE VOCÊ CONSTRUIU

Em pouco mais de 300 linhas de SML, uma implementação completa de uma linguagem de programação: análise léxica, análise sintática, um interpretador, e dois compiladores para alvos muito diferentes. Quase tudo foi feito com as ferramentas do curso:

```
ferramenta                         onde apareceu
---------------------------------  ---------------------------------------------
datatype recursivo (Tema 56)       exp, a árvore do programa
um caso por construtor (Tema 57)   valueOf, racketDe, forthDe
pulo do gato (Tema 19)             valueOf numa árvore: confiar nos filhos
pertence? (Tema 29)                applyEnv
acumulador (Tema 69)               lerEnquanto, profundidade
inverter no fim (Tema 74)          lerEnquanto
notação posfixa (Tema 2)           forthDe
escopo léxico                      ambiente do interpretador = pilha do compilador
dinâmico vs estático (Tema 66)     erros de tipo de LET, nos três executores
```

### EXERCÍCIOS DO LIVRO

Os exercícios do EOPL pedem para estender a linguagem. Aqui, cada extensão mexe em até cinco lugares: o `datatype`, o scanner, o parser, o interpretador e os compiladores. A boa notícia: quando você acrescenta um construtor ao `datatype exp`, o compilador de SML avisa `match nonexhaustive` em CADA função que ainda não trata o construtor novo. A lista de avisos é a lista de tarefas.

- 95.1 (Exercício 3.6 do livro) Acrescente `minus(e)`, que devolve o oposto de e: `minus(-(minus(5), 9))` vale 14. Em Forth, existe a palavra `NEGATE`.
- 95.2 (Exercício 3.7) Acrescente soma, multiplicação e quociente inteiro: `+(e1, e2)`, `*(e1, e2)`, `/(e1, e2)`. O que deveria acontecer na divisão por zero, em cada um dos três executores?
- 95.3 (Exercício 3.8) Acrescente `equal?(e1, e2)`, `greater?(e1, e2)` e `less?(e1, e2)`. Em Forth, procure `=`, `>` e `<`.
- 95.4 (Exercício 3.9) Acrescente listas: `cons(e1, e2)`, `car(e)`, `cdr(e)`, `null?(e)` e `emptylist`. Você vai precisar de um construtor novo em `expval`. Faça só o interpretador e o compilador para Racket - por que o de Forth seria muito mais difícil?
- 95.5 (Exercício 3.12) Acrescente `cond e1 ==> e2 ... end`: avalia as condições em ordem e devolve o valor associado à primeira verdadeira.
- 95.6 (Exercício 3.16) Permita `let` com várias declarações: `let x = 30 in let x = -(x,1) y = -(x,2) in -(x,y)` vale 1. Atenção: todas as expressões do lado direito são calculadas no ambiente de FORA.
- 95.7 (Exercício 3.17) Acrescente `let*`, em que cada declaração já enxerga as anteriores: com `let*` no lugar do `let` interno do exercício anterior, o resultado é 2.
- 95.8 Escreva um verificador de tipos para LET (o esboço do 87.3): `tipoDe : exp * (string * tipo) list -> tipo`, com `datatype tipo = Int | Bool`. Use-o antes de compilar, e os dois compiladores passam a ser corretos para todos os programas que ele aceitar. Por quê?

## FIM DO TUTORIAL DA LINGUAGEM LET
