(* ============================================================================
   exemplos.sml - exemplos em SML demonstrados em tutorial-acumuladores.txt
   ============================================================================
   Carregue com:
       sml exemplos.sml
   ou, dentro do REPL:  use "exemplos.sml";

   Cada funcao deste arquivo tem uma gemea em exemplos.rkt, com o mesmo
   numero de tema. Listas nativas (Tema 62) e anotacao de tipo em tudo:
   o tipo do acumulador e justamente o que mais vale a pena escrever.

   Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
   exercicio esta aqui.
   ========================================================================= *)

(* --- Tema 68: a recursao que trabalha na volta ---------------------------- *)

fun somar ([] : int list) : int = 0
  | somar (cabeca :: cauda : int list) : int = cabeca + somar cauda;
(* somar [4, 6, 0, 2]  =>  12 *)

(* --- Tema 69: somar com acumulador ---------------------------------------- *)

fun somarAcc ([] : int list, acc : int) : int = acc
  | somarAcc (cabeca :: cauda : int list, acc : int) : int =
        somarAcc (cauda, acc + cabeca);
(* somarAcc ([4, 6, 0, 2], 0)    =>  12  *)
(* somarAcc ([4, 6, 0, 2], 100)  =>  112 *)

(* --- Tema 70: o embrulho -------------------------------------------------- *)

fun somarIt (l : int list) : int =
    let
        fun laco ([] : int list, acc : int) : int = acc
          | laco (cabeca :: cauda : int list, acc : int) : int =
                laco (cauda, acc + cabeca)
    in
        laco (l, 0)
    end;
(* somarIt [4, 6, 0, 2]  =>  12 *)

(* --- Tema 71: mais resultados numericos ----------------------------------- *)

fun comprimentoAcc ([] : 'a list, acc : int) : int = acc
  | comprimentoAcc (_ :: cauda : 'a list, acc : int) : int =
        comprimentoAcc (cauda, acc + 1);
(* comprimentoAcc ([5, 1, 4, 6, 10], 0)  =>  5 *)

fun contarAcc (x : ''a, [] : ''a list, acc : int) : int = acc
  | contarAcc (x : ''a, cabeca :: cauda : ''a list, acc : int) : int =
        if x = cabeca then contarAcc (x, cauda, acc + 1)
        else contarAcc (x, cauda, acc);
(* contarAcc (3, [3, 5, 3, 1], 0)  =>  2 *)

(* --- Tema 72: resultados logicos ------------------------------------------ *)

fun pertence (x : ''a, [] : ''a list) : bool = false
  | pertence (x : ''a, cabeca :: cauda : ''a list) : bool =
        x = cabeca orelse pertence (x, cauda);
(* pertence (3, [0, 3, 1, 4])  =>  true *)

fun comprimentoParAcc ([] : 'a list, acc : bool) : bool = acc
  | comprimentoParAcc (_ :: cauda : 'a list, acc : bool) : bool =
        comprimentoParAcc (cauda, not acc);
(* comprimentoParAcc ([1, 2, 3, 4], true)  =>  true  *)
(* comprimentoParAcc ([1, 2, 3], true)     =>  false *)

fun semVizinhosIguaisAcc (anterior : ''a, [] : ''a list) : bool = true
  | semVizinhosIguaisAcc (anterior : ''a, cabeca :: cauda : ''a list) : bool =
        anterior <> cabeca andalso semVizinhosIguaisAcc (cabeca, cauda);

fun semVizinhosIguais ([] : ''a list) : bool = true
  | semVizinhosIguais (cabeca :: cauda : ''a list) : bool =
        semVizinhosIguaisAcc (cabeca, cauda);
(* semVizinhosIguais [1, 2, 1, 2]  =>  true  *)
(* semVizinhosIguais [1, 2, 2, 3]  =>  false *)

(* --- Tema 73: reverse ----------------------------------------------------- *)

fun inverter ([] : 'a list) : 'a list = []
  | inverter (cabeca :: cauda : 'a list) : 'a list = inverter cauda @ [cabeca];
(* inverter [1, 2, 3, 4]  =>  [4, 3, 2, 1] *)

fun inverterAcc ([] : 'a list, acc : 'a list) : 'a list = acc
  | inverterAcc (cabeca :: cauda : 'a list, acc : 'a list) : 'a list =
        inverterAcc (cauda, cabeca :: acc);
(* inverterAcc ([1, 2, 3, 4], [])  =>  [4, 3, 2, 1] *)

fun inverterIt (l : 'a list) : 'a list = inverterAcc (l, []);

(* Para medir (Tema 73):
   fun cronometrar (f : unit -> 'a) : unit =
       let val t = Timer.startRealTimer ()
           val _ = f ()
       in print (Time.toString (Timer.checkRealTimer t) ^ " s\n") end;
   val grande : int list = List.tabulate (20000, fn i => i);
   cronometrar (fn () => inverter grande);     ~ 1 segundo
   cronometrar (fn () => inverterIt grande);   0.000 s                       *)

(* --- Tema 74: listas como resultado, e a ordem invertida ------------------- *)

fun dobrarAccErrado ([] : int list, acc : int list) : int list = acc
  | dobrarAccErrado (cabeca :: cauda : int list, acc : int list) : int list =
        dobrarAccErrado (cauda, 2 * cabeca :: acc);
(* dobrarAccErrado ([6, 7, 1, ~3, 0], [])  =>  [0, ~6, 2, 14, 12] *)

fun dobrarAcc ([] : int list, acc : int list) : int list = inverterIt acc
  | dobrarAcc (cabeca :: cauda : int list, acc : int list) : int list =
        dobrarAcc (cauda, 2 * cabeca :: acc);
(* dobrarAcc ([6, 7, 1, ~3, 0], [])  =>  [12, 14, 2, ~6, 0] *)

fun mapAcc (f : 'a -> 'b, [] : 'a list, acc : 'b list) : 'b list = inverterIt acc
  | mapAcc (f : 'a -> 'b, cabeca :: cauda : 'a list, acc : 'b list) : 'b list =
        mapAcc (f, cauda, f cabeca :: acc);
(* mapAcc (fn (x : int) => x + 1, [4, 3, 8], [])  =>  [5, 4, 9] *)

fun filtrarAcc (p : 'a -> bool, [] : 'a list, acc : 'a list) : 'a list =
        inverterIt acc
  | filtrarAcc (p : 'a -> bool, cabeca :: cauda : 'a list, acc : 'a list) : 'a list =
        if p cabeca then filtrarAcc (p, cauda, cabeca :: acc)
        else filtrarAcc (p, cauda, acc);
(* filtrarAcc (fn (x : int) => x mod 2 = 0, [2, 3, 4, 6, 7, 10], [])
   =>  [2, 4, 6, 10] *)

(* --- Tema 75: quando a ordem invertida e uma vantagem --------------------- *)

fun enumerarAcc (0 : int, acc : int list) : int list = acc
  | enumerarAcc (n : int, acc : int list) : int list =
        enumerarAcc (n - 1, n :: acc);
(* enumerarAcc (5, [])  =>  [1, 2, 3, 4, 5] *)

(* inverterAcc ([3, 2, 1], [4, 5])  =>  [1, 2, 3, 4, 5] *)

fun juntarIt (l1 : 'a list, l2 : 'a list) : 'a list =
    inverterAcc (inverterIt l1, l2);
(* juntarIt ([4, 5], [10, 15])  =>  [4, 5, 10, 15] *)
(* na biblioteca: List.revAppend ([3, 2, 1], [4, 5])  =>  [1, 2, 3, 4, 5] *)

(* --- Tema 76: meuFoldl, o esqueleto do acumulador ------------------------- *)

fun meuFoldl (f : 'a * 'b -> 'b) (acc : 'b) ([] : 'a list) : 'b = acc
  | meuFoldl (f : 'a * 'b -> 'b) (acc : 'b) (cabeca :: cauda : 'a list) : 'b =
        meuFoldl f (f (cabeca, acc)) cauda;
(* meuFoldl (op +) 0 [4, 6, 0, 2]                         =>  12          *)
(* meuFoldl (fn (_, acc : int) => acc + 1) 0 [5, 1, 4]     =>  3           *)
(* meuFoldl (op ::) [] [1, 2, 3, 4]                        =>  [4,3,2,1]   *)
(* nativo: foldl (op ::) [] [1, 2, 3, 4]                   =>  [4,3,2,1]   *)

(* --- Tema 77: meuFoldr, o esqueleto SEM acumulador ------------------------ *)

fun meuFoldr (f : 'a * 'b -> 'b) (inicial : 'b) ([] : 'a list) : 'b = inicial
  | meuFoldr (f : 'a * 'b -> 'b) (inicial : 'b) (cabeca :: cauda : 'a list) : 'b =
        f (cabeca, meuFoldr f inicial cauda);
(* meuFoldr (op +) 0 [4, 6, 0, 2]       =>  12          *)
(* meuFoldr (op ::) [] [1, 2, 3, 4]     =>  [1,2,3,4]   *)
(* foldl (op -) 0 [1, 2, 3, 4]          =>  2           *)
(* foldr (op -) 0 [1, 2, 3, 4]          =>  ~2          *)

(* --- Tema 79: tudo e fold ------------------------------------------------- *)

fun somarF (l : int list) : int = foldl (op +) 0 l;
fun comprimentoF (l : 'a list) : int = foldl (fn (_, acc : int) => acc + 1) 0 l;
fun inverterF (l : 'a list) : 'a list = foldl (op ::) [] l;
fun mapF (f : 'a -> 'b) (l : 'a list) : 'b list =
    foldr (fn (x : 'a, acc : 'b list) => f x :: acc) [] l;
fun filtrarF (p : 'a -> bool) (l : 'a list) : 'a list =
    foldr (fn (x : 'a, acc : 'a list) => if p x then x :: acc else acc) [] l;
fun existeF (p : 'a -> bool) (l : 'a list) : bool =
    foldl (fn (x : 'a, acc : bool) => acc orelse p x) false l;
(* somarF [4, 6, 0, 2]                        =>  12        *)
(* comprimentoF [3, 1, 4]                     =>  3         *)
(* inverterF [1, 2, 3]                        =>  [3,2,1]   *)
(* mapF (fn (x : int) => x + 1) [4, 3, 8]     =>  [5,4,9]   *)
(* filtrarF (fn (x : int) => x mod 2 = 0) [2, 3, 4, 7]   =>  [2,4]  *)
(* existeF (fn (x : int) => x < 0) [1, 3, ~1]            =>  true   *)

(* Acumulador composto: soma e contagem viajando juntas, numa tupla. *)
fun media (l : int list) : real =
    let
        val (soma, quantos) : int * int =
            foldl (fn (x : int, (s : int, n : int)) => (s + x, n + 1)) (0, 0) l
    in
        real soma / real quantos
    end;
(* media [4, 6, 0, 2]  =>  3.0 *)
(* media [1, 2]        =>  1.5 *)
