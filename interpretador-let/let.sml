(* ============================================================================
   let.sml - a linguagem LET (EOPL, 3a ed., secao 3.2): interpretador e dois
             compiladores, um para Racket e um para Forth
   ============================================================================
   Codigo construido em tutorial-let.txt, Temas 81 a 94, na mesma ordem.

   Carregue com:
       sml let.sml
   ou, dentro do REPL:  use "let.sml";

   Depois de carregado:
       rodar "let x = 5 in -(x, 3)";            o interpretador
       paraRacket (ler "let x = 5 in -(x, 3)"); o compilador para Racket
       paraForth (ler "let x = 5 in -(x, 3)");  o compilador para Forth
       comparar "let x = 5 in -(x, 3)";         os tres lado a lado
                                                (precisa de racket e gforth)

   Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
   exercicio esta aqui.
   ========================================================================= *)

(* Sem isto, o REPL abrevia as arvores mais fundas com # . *)
Control.Print.printDepth := 20;

(* --- Tema 82: sintaxe abstrata -------------------------------------------- *)
(* Um construtor para cada regra da gramatica. *)

datatype exp =
    ConstExp of int                    (* 5                        *)
  | DiffExp  of exp * exp              (* -(e1, e2)                *)
  | ZeroExp  of exp                    (* zero?(e)                 *)
  | IfExp    of exp * exp * exp        (* if e1 then e2 else e3    *)
  | VarExp   of string                 (* x                        *)
  | LetExp   of string * exp * exp;    (* let x = e1 in e2         *)

datatype program = AProgram of exp;

(* let x = 5 in -(x, 3), escrito a mao: *)
val exemplo1 : program =
    AProgram (LetExp ("x", ConstExp 5, DiffExp (VarExp "x", ConstExp 3)));

(* --- Tema 83: valores ----------------------------------------------------- *)

datatype expval = NumVal of int | BoolVal of bool;

exception ErroDeTipo of string;

fun expvalParaNum (NumVal n : expval) : int = n
  | expvalParaNum (BoolVal _ : expval) : int =
        raise ErroDeTipo "esperava um numero, veio um booleano";

fun expvalParaBool (BoolVal b : expval) : bool = b
  | expvalParaBool (NumVal _ : expval) : bool =
        raise ErroDeTipo "esperava um booleano, veio um numero";

(* --- Tema 84: ambientes --------------------------------------------------- *)
(* Uma lista de pares: o par mais recente fica na frente. *)

type env = (string * expval) list;

exception VariavelLivre of string;

val emptyEnv : env = [];

fun extendEnv (x : string, v : expval, e : env) : env = (x, v) :: e;

fun applyEnv ([] : env, x : string) : expval = raise VariavelLivre x
  | applyEnv ((y, v) :: resto : env, x : string) : expval =
        if x = y then v else applyEnv (resto, x);

(* O ambiente inicial do livro: i = 1, v = 5, x = 10. *)
val initEnv : env =
    extendEnv ("i", NumVal 1,
      extendEnv ("v", NumVal 5,
        extendEnv ("x", NumVal 10, emptyEnv)));

(* --- Tema 85: o interpretador --------------------------------------------- *)
(* Uma clausula para cada construtor de exp - um caso por construtor,
   como no Tema 57. *)

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
(* valueOfProgram exemplo1  =>  NumVal 2 *)

(* -(-(x, 3), -(v, i)), o primeiro exemplo do livro: *)
val exemplo2 : program =
    AProgram (DiffExp (DiffExp (VarExp "x", ConstExp 3),
                       DiffExp (VarExp "v", VarExp "i")));
(* valueOfProgram exemplo2  =>  NumVal 3 *)

(* --- Tema 88: analise lexica ---------------------------------------------- *)

datatype token =
    NUM of int | ID of string
  | MENOS | ABRE | FECHA | VIRGULA | IGUAL
  | ZERO | IF | THEN | ELSE | LET | IN;

exception ErroLexico of string;

(* Le caracteres enquanto p valer. acc guarda, INVERTIDOS, os ja lidos
   (Tema 74): por isso o rev no fim. Devolve a palavra e o que sobrou. *)
fun lerEnquanto (p : char -> bool, [] : char list, acc : char list)
        : string * char list =
        (implode (rev acc), [])
  | lerEnquanto (p : char -> bool, c :: cs : char list, acc : char list)
        : string * char list =
        if p c then lerEnquanto (p, cs, c :: acc)
        else (implode (rev acc), c :: cs);

fun ehDoNome (c : char) : bool = Char.isAlphaNum c orelse c = #"?" orelse c = #"_";

fun palavra (s : string) : token =
    case s of
        "zero?" => ZERO
      | "if"    => IF
      | "then"  => THEN
      | "else"  => ELSE
      | "let"   => LET
      | "in"    => IN
      | _       => ID s;

fun numero (s : string) : int = valOf (Int.fromString s);

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

(* scan (explode "let x = 5 in -(x, 3)")
   =>  [LET, ID "x", IGUAL, NUM 5, IN, MENOS, ABRE, ID "x", VIRGULA, NUM 3, FECHA] *)

(* --- Tema 89: analise sintatica ------------------------------------------- *)
(* Descendente recursiva: cada funcao consome do inicio da lista de tokens
   a parte que reconhece e devolve o que reconheceu E o que sobrou. *)

exception ErroSintatico of string;

fun mostrarToken (NUM n : token) : string = Int.toString n
  | mostrarToken (ID x) = x
  | mostrarToken MENOS = "-"   | mostrarToken ABRE = "("
  | mostrarToken FECHA = ")"   | mostrarToken VIRGULA = ","
  | mostrarToken IGUAL = "="   | mostrarToken ZERO = "zero?"
  | mostrarToken IF = "if"     | mostrarToken THEN = "then"
  | mostrarToken ELSE = "else" | mostrarToken LET = "let"
  | mostrarToken IN = "in";

fun entreAspas (t : token) : string = "'" ^ mostrarToken t ^ "'";

(* Consome um token que TEM que estar ali. *)
fun esperar (t : token, [] : token list) : token list =
        raise ErroSintatico ("esperava " ^ entreAspas t ^ ", o programa acabou")
  | esperar (t : token, t' :: resto : token list) : token list =
        if t = t' then resto
        else raise ErroSintatico ("esperava " ^ entreAspas t ^
                                  ", veio " ^ entreAspas t');

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
  | parseExp (ZERO :: r0) =                         (* zero?(e) *)
        let
            val r1 = esperar (ABRE, r0)
            val (e, r2) = parseExp r1
            val r3 = esperar (FECHA, r2)
        in
            (ZeroExp e, r3)
        end
  | parseExp (IF :: r0) =                           (* if e1 then e2 else e3 *)
        let
            val (e1, r1) = parseExp r0
            val r2 = esperar (THEN, r1)
            val (e2, r3) = parseExp r2
            val r4 = esperar (ELSE, r3)
            val (e3, r5) = parseExp r4
        in
            (IfExp (e1, e2, e3), r5)
        end
  | parseExp (LET :: ID x :: r0) =                  (* let x = e1 in e2 *)
        let
            val r1 = esperar (IGUAL, r0)
            val (e1, r2) = parseExp r1
            val r3 = esperar (IN, r2)
            val (e2, r4) = parseExp r3
        in
            (LetExp (x, e1, e2), r4)
        end
  | parseExp (LET :: t :: _) =
        raise ErroSintatico ("esperava um nome depois de 'let', veio " ^ entreAspas t)
  | parseExp (t :: _) =
        raise ErroSintatico ("uma expressao nao pode comecar com " ^ entreAspas t)
  | parseExp [] = raise ErroSintatico "esperava uma expressao, o programa acabou";

(* --- Tema 90: juntando tudo ----------------------------------------------- *)

fun ler (texto : string) : program =
    case parseExp (scan (explode texto)) of
        (e, []) => AProgram e
      | (_, t :: _) => raise ErroSintatico ("sobrou texto a partir de " ^ entreAspas t);

(* Inteiros negativos no estilo de todo mundo: -3, e nao ~3. *)
fun intParaTexto (n : int) : string =
    if n < 0 then "-" ^ Int.toString (~ n) else Int.toString n;

fun mostrar (NumVal n : expval) : string = intParaTexto n
  | mostrar (BoolVal b : expval) : string = Bool.toString b;

(* O REPL mostra so o NOME de uma excecao nao tratada; aqui ela vira texto,
   com a mensagem que carrega. *)
fun rodar (texto : string) : string =
    mostrar (valueOfProgram (ler texto))
    handle ErroLexico m    => "erro lexico: " ^ m
         | ErroSintatico m => "erro sintatico: " ^ m
         | VariavelLivre x => "erro: variavel livre " ^ x
         | ErroDeTipo m    => "erro de tipo: " ^ m;

(* rodar "-(-(x, 3), -(v, i))"   =>  "3" *)
(* rodar "let z = 5 in let x = 3 in let y = -(x, 1) in let x = 4 in -(z, -(x, y))"
   =>  "3" *)

(* --- Tema 92: compilador para Racket -------------------------------------- *)

fun racketDe (ConstExp n : exp) : string = intParaTexto n
  | racketDe (VarExp x) = x
  | racketDe (DiffExp (e1, e2)) = "(- " ^ racketDe e1 ^ " " ^ racketDe e2 ^ ")"
  | racketDe (ZeroExp e) = "(zero? " ^ racketDe e ^ ")"
  | racketDe (IfExp (e1, e2, e3)) =
        "(if " ^ racketDe e1 ^ " " ^ racketDe e2 ^ " " ^ racketDe e3 ^ ")"
  | racketDe (LetExp (x, e1, corpo)) =
        "(let ([" ^ x ^ " " ^ racketDe e1 ^ "]) " ^ racketDe corpo ^ ")";

(* O ambiente inicial vira um let em volta do programa inteiro. *)
fun paraRacket (AProgram e : program) : string =
    "#lang racket\n(let ([i 1] [v 5] [x 10])\n  " ^ racketDe e ^ ")\n";

(* --- Tema 93: compilador para Forth --------------------------------------- *)
(* pilha descreve, em tempo de compilacao, o que estara na pilha do Forth
   quando o codigo rodar: SOME x e a variavel x, NONE e um valor temporario.
   O topo da pilha e a cabeca da lista. *)

fun profundidade (x : string, [] : string option list, n : int) : int =
        raise VariavelLivre x
  | profundidade (x : string, SOME y :: resto : string option list, n : int) : int =
        if x = y then n else profundidade (x, resto, n + 1)
  | profundidade (x : string, NONE :: resto : string option list, n : int) : int =
        profundidade (x, resto, n + 1);

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

(* O ambiente inicial vira tres numeros empilhados: i no fundo, x no topo. *)
val pilhaInicial : string option list = [SOME "x", SOME "v", SOME "i"];

fun paraForth (AProgram e : program) : string =
    ": programa\n  1 5 10\n  " ^
    String.concatWith " " (forthDe (e, pilhaInicial)) ^
    "\n  NIP NIP NIP ;\nprograma . CR\nbye\n";

(* --- Tema 94: os tres lado a lado ----------------------------------------- *)

fun gravar (arquivo : string, texto : string) : unit =
    let
        val saida = TextIO.openOut arquivo
    in
        TextIO.output (saida, texto);
        TextIO.closeOut saida
    end;

fun comparar (texto : string) : unit =
    let
        val p = ler texto
    in
        print ("interpretador: " ^ rodar texto ^ "\n");
        gravar ("saida.rkt", paraRacket p);
        print "racket.......: ";
        OS.Process.system "racket saida.rkt";
        gravar ("saida.fs", paraForth p);
        print "gforth.......: ";
        OS.Process.system "gforth saida.fs";
        ()
    end;
