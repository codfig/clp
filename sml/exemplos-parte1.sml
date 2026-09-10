(* ============================================================================
   exemplos-parte1.sml - exemplos demonstrados em tutorial-sml-parte1.txt
   ============================================================================
   Carregue de um destes jeitos:
       - terminal: sml exemplos-parte1.sml   (executa e VOLTA ao terminal)
       - dentro do REPL: use "exemplos-parte1.sml";
       - VS Code: abra um terminal, rode sml e use o mesmo use "..."; de cima

   Depois de carregado, chame as funcoes no REPL - os comentarios (* => *)
   mostram o que esperar.

   REGRA DA CASA desta parte: TODO valor e TODA funcao levam anotacao de tipo
   explicita. A inferencia de tipos existe e funciona, mas so entra em cena no
   Tema 64 da parte 2 - ate la, quem declara o tipo e voce.

   Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
   exercicio esta aqui.
   ========================================================================= *)

(* --- Tema 45: tipos basicos ---------------------------------------------- *)

val idade : int = 20;
val altura : real = 1.75;
val inicial : char = #"o";
val nome : string = "Ada";
val maior : bool = true;

(* --- Tema 46: val e anotacao de tipo ------------------------------------- *)

val dobro : int = 2 * idade;                    (* => 40 *)
val saudacao : string = "Olá, " ^ nome ^ "!";   (* => "Olá, Ada!" *)

(* --- Tema 47: funcoes com fun -------------------------------------------- *)

fun quadrado (x : int) : int = x * x;
(* quadrado 5  =>  25 *)

fun media (a : real, b : real) : real = (a + b) / 2.0;
(* media (7.0, 10.0)  =>  8.5 *)

fun repetir (s : string, n : int) : string =
    if n <= 0 then "" else s ^ repetir (s, n - 1);
(* repetir ("ab", 3)  =>  "ababab" *)

(* --- Tema 48: if/then/else como expressao -------------------------------- *)

fun absoluto (x : int) : int = if x < 0 then ~x else x;
(* absoluto ~7  =>  7 *)

fun classificar (n : int) : string =
    if n < 0 then "negativo"
    else if n = 0 then "zero"
    else "positivo";
(* classificar ~3  =>  "negativo" *)

(* --- Tema 49: let ... in ... end ----------------------------------------- *)

fun distancia (x1 : real, y1 : real, x2 : real, y2 : real) : real =
    let
        val dx : real = x2 - x1
        val dy : real = y2 - y1
    in
        Math.sqrt (dx * dx + dy * dy)
    end;
(* distancia (0.0, 0.0, 3.0, 4.0)  =>  5.0 *)

(* --- Tema 50: recursao --------------------------------------------------- *)

fun fatorial (n : int) : int =
    if n = 0 then 1 else n * fatorial (n - 1);
(* fatorial 5  =>  120 *)

fun somaAte (n : int) : int =
    if n = 0 then 0 else n + somaAte (n - 1);
(* somaAte 10  =>  55 *)

(* --- Tema 51: casamento de padroes --------------------------------------- *)

fun fatorial2 (0 : int) : int = 1
  | fatorial2 (n : int) : int = n * fatorial2 (n - 1);
(* fatorial2 5  =>  120 *)

fun fibonacci (0 : int) : int = 0
  | fibonacci (1 : int) : int = 1
  | fibonacci (n : int) : int = fibonacci (n - 1) + fibonacci (n - 2);
(* fibonacci 10  =>  55 *)

fun sinal (n : int) : string =
    case n of
        0 => "zero"
      | _ => if n < 0 then "negativo" else "positivo";
(* sinal 0  =>  "zero" *)

(* --- Tema 52: tipos produto (tuplas e records) --------------------------- *)

type Ponto = real * real;

val origem : Ponto = (0.0, 0.0);
val p : Ponto = (3.0, 4.0);

fun somaX (a : Ponto, b : Ponto) : real =
    let
        val (x1 : real, _) = a
        val (x2 : real, _) = b
    in
        x1 + x2
    end;
(* somaX (origem, p)  =>  3.0 *)

type Aluno = { nome : string, matricula : int, media : real };

val ana : Aluno = { nome = "Ana", matricula = 202601, media = 8.5 };

fun aprovado (a : Aluno) : bool = #media a >= 6.0;
(* aprovado ana  =>  true *)

(* --- Tema 53: tipos soma (datatype) -------------------------------------- *)

datatype Cor = Vermelho | Verde | Azul;

fun hex (c : Cor) : string =
    case c of
        Vermelho => "#FF0000"
      | Verde    => "#00FF00"
      | Azul     => "#0000FF";
(* hex Verde  =>  "#00FF00" *)

datatype Tema = Claro | Escuro;

fun fundo (t : Tema) : Cor =
    case t of
        Claro  => Azul
      | Escuro => Vermelho;
(* fundo Escuro  =>  Vermelho *)

fun inverter (t : Tema) : Tema =
    case t of
        Claro  => Escuro
      | Escuro => Claro;
(* inverter Claro  =>  Escuro *)

(* --- Tema 54: soma DE produtos: a forma de pagamento --------------------- *)

datatype Pagamento =
      Cartao of string * int
    | Pix    of string
    | Boleto of int;

val compra1 : Pagamento = Cartao ("4111111111111111", 3);
val compra2 : Pagamento = Pix "ana@exemplo.br";
val compra3 : Pagamento = Boleto 5;

fun descricao (p : Pagamento) : string =
    case p of
        Cartao (numero, parcelas) =>
            "cartão final " ^ String.extract (numero, size numero - 4, NONE)
            ^ " em " ^ Int.toString parcelas ^ "x"
      | Pix chave =>
            "pix para " ^ chave
      | Boleto dias =>
            "boleto em " ^ Int.toString dias ^ " dias";
(* descricao compra1  =>  "cartão final 1111 em 3x" *)

fun taxa (p : Pagamento, valor : real) : real =
    case p of
        Cartao (_, parcelas) => if parcelas > 1 then valor * 0.03 else 0.0
      | Pix _                => 0.0
      | Boleto _             => 2.50;
(* taxa (compra1, 100.0)  =>  3.0 *)
