(* ============================================================================
   exemplos-parte2.sml - a Lizt MONOMORFICA (Temas 56 a 59)
   ============================================================================
   Exemplos demonstrados em tutorial-sml-parte2.txt, primeira metade: a lista
   construida por nos, so de inteiros.

   Carregue com:
       sml exemplos-parte2.sml
   ou, dentro do REPL:  use "exemplos-parte2.sml";

   CUIDADO: NAO carregue este arquivo junto com exemplos-parte2-poli.sml no
   mesmo REPL. Os dois declaram um tipo chamado Lizt, e o segundo ESCONDE
   (shadowing) o primeiro - o REPL passa a imprimir ?.Lizt nos valores antigos.
   Um arquivo por REPL; para trocar, saia e entre de novo.

   REGRA DA CASA (ainda valendo): todo val e toda funcao levam anotacao de tipo
   explicita. A inferencia so entra no Tema 64.

   Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
   exercicio esta aqui.
   ========================================================================= *)

(* --- Tema 56: a lista construida por nos --------------------------------- *)

datatype Lizt = Nihil | Kons of int * Lizt;

val vazia : Lizt = Nihil;
val umItem : Lizt = Kons (7, Nihil);
val l1 : Lizt = Kons (4, Kons (6, Kons (0, Kons (2, Nihil))));
val l2 : Lizt = Kons (10, Kons (20, Nihil));

(* --- Tema 57: recursao sobre Lizt ---------------------------------------- *)

fun somar (Nihil : Lizt) : int = 0
  | somar (Kons (cabeca, cauda) : Lizt) : int = cabeca + somar cauda;
(* somar l1  =>  12 *)

fun comprimento (Nihil : Lizt) : int = 0
  | comprimento (Kons (_, cauda) : Lizt) : int = 1 + comprimento cauda;
(* comprimento l1  =>  4 *)

(* Dois casos base: a lista de um elemento so, e a lista vazia - que aqui nao
   tem resposta possivel, entao levanta a excecao Empty. *)
fun maiorDe (Kons (cabeca, Nihil) : Lizt) : int = cabeca
  | maiorDe (Kons (cabeca, cauda) : Lizt) : int =
        Int.max (cabeca, maiorDe cauda)
  | maiorDe (Nihil : Lizt) : int = raise Empty;
(* maiorDe l1  =>  6 *)
(* maiorDe Nihil  =>  uncaught exception Empty *)

(* --- Tema 58: quando a resposta e outra Lizt ----------------------------- *)

fun dobrar (Nihil : Lizt) : Lizt = Nihil
  | dobrar (Kons (cabeca, cauda) : Lizt) : Lizt =
        Kons (2 * cabeca, dobrar cauda);
(* dobrar l1  =>  Kons (8,Kons (12,Kons (0,Kons (4,Nihil)))) *)

fun juntar (Nihil : Lizt, l2 : Lizt) : Lizt = l2
  | juntar (Kons (cabeca, cauda) : Lizt, l2 : Lizt) : Lizt =
        Kons (cabeca, juntar (cauda, l2));
(* juntar (l2, umItem)  =>  Kons (10,Kons (20,Kons (7,Nihil))) *)

fun soPares (Nihil : Lizt) : Lizt = Nihil
  | soPares (Kons (cabeca, cauda) : Lizt) : Lizt =
        if cabeca mod 2 = 0 then Kons (cabeca, soPares cauda)
        else soPares cauda;
(* soPares (Kons (1, Kons (2, Kons (3, Kons (4, Nihil)))))
       =>  Kons (2,Kons (4,Nihil)) *)

(* --- Tema 59: retorno booleano ------------------------------------------- *)

fun pertence (_ : int, Nihil : Lizt) : bool = false
  | pertence (alvo : int, Kons (cabeca, cauda) : Lizt) : bool =
        alvo = cabeca orelse pertence (alvo, cauda);
(* pertence (6, l1)  =>  true *)
(* pertence (9, l1)  =>  false *)

fun todosPositivos (Nihil : Lizt) : bool = true
  | todosPositivos (Kons (cabeca, cauda) : Lizt) : bool =
        cabeca > 0 andalso todosPositivos cauda;
(* todosPositivos l2  =>  true *)
(* todosPositivos l1  =>  false *)
