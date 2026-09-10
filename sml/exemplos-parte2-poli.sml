(* ============================================================================
   exemplos-parte2-poli.sml - Lizt POLIMORFICA, listas nativas e inferencia
                              (Temas 60 a 67)
   ============================================================================
   Exemplos demonstrados em tutorial-sml-parte2.txt, segunda metade.

   Carregue com:
       sml exemplos-parte2-poli.sml
   ou, dentro do REPL:  use "exemplos-parte2-poli.sml";

   CUIDADO: NAO carregue este arquivo junto com exemplos-parte2.sml no mesmo
   REPL. Os dois declaram um tipo chamado Lizt, e o segundo ESCONDE (shadowing)
   o primeiro - o REPL passa a imprimir ?.Lizt nos valores antigos. Um arquivo
   por REPL; para trocar, saia e entre de novo.

   REGRA DA CASA: ela vale ate o Tema 63. A partir do Tema 64 as anotacoes
   somem DE PROPOSITO - o assunto passa a ser exatamente o que o compilador
   descobre sozinho.

   Este arquivo contem SOMENTE o que o texto demonstra. Nenhuma resposta de
   exercicio esta aqui.
   ========================================================================= *)

(* --- Tema 60: um tipo, qualquer conteudo --------------------------------- *)

datatype 'a Lizt = Nihil | Kons of 'a * 'a Lizt;

val numeros : int Lizt = Kons (4, Kons (6, Kons (0, Kons (2, Nihil))));
val palavras : string Lizt = Kons ("olá", Kons ("mundo", Nihil));
val flags : bool Lizt = Kons (true, Kons (false, Nihil));
val listaDeListas : (int Lizt) Lizt = Kons (numeros, Kons (Nihil, Nihil));

(* Uma unica definicao serve para todas as listas acima. *)
fun comprimento (Nihil : 'a Lizt) : int = 0
  | comprimento (Kons (_, cauda) : 'a Lizt) : int = 1 + comprimento cauda;
(* comprimento numeros   =>  4 *)
(* comprimento palavras  =>  2 *)

fun juntar (Nihil : 'a Lizt, outra : 'a Lizt) : 'a Lizt = outra
  | juntar (Kons (cabeca, cauda) : 'a Lizt, outra : 'a Lizt) : 'a Lizt =
        Kons (cabeca, juntar (cauda, outra));
(* juntar (palavras, Kons ("!", Nihil))
       =>  Kons ("olá",Kons ("mundo",Kons ("!",Nihil))) *)

(* Igualdade exige um tipo de igualdade: repare nas DUAS aspas em ''a. *)
fun pertence (_ : ''a, Nihil : ''a Lizt) : bool = false
  | pertence (alvo : ''a, Kons (cabeca, cauda) : ''a Lizt) : bool =
        alvo = cabeca orelse pertence (alvo, cauda);
(* pertence (6, numeros)        =>  true *)
(* pertence ("mundo", palavras) =>  true *)

(* --- Tema 61: funcoes de ordem superior, agora polimorficas -------------- *)

fun mapL (f : 'a -> 'b) (Nihil : 'a Lizt) : 'b Lizt = Nihil
  | mapL (f : 'a -> 'b) (Kons (cabeca, cauda) : 'a Lizt) : 'b Lizt =
        Kons (f cabeca, mapL f cauda);
(* mapL (fn (x : int) => 2 * x) numeros
       =>  Kons (8,Kons (12,Kons (0,Kons (4,Nihil)))) *)
(* mapL (fn (x : int) => Int.toString x) numeros
       =>  Kons ("4",Kons ("6",Kons ("0",Kons ("2",Nihil)))) *)

fun filtrarL (p : 'a -> bool) (Nihil : 'a Lizt) : 'a Lizt = Nihil
  | filtrarL (p : 'a -> bool) (Kons (cabeca, cauda) : 'a Lizt) : 'a Lizt =
        if p cabeca then Kons (cabeca, filtrarL p cauda)
        else filtrarL p cauda;
(* filtrarL (fn (x : int) => x > 2) numeros
       =>  Kons (4,Kons (6,Nihil)) *)

(* --- Tema 62: a lista nativa e o mesmo datatype com outra roupa ---------- *)

val nativa : int list = 4 :: 6 :: 0 :: 2 :: [];
val mesmaCoisa : int list = [4, 6, 0, 2];
(* nativa = mesmaCoisa  =>  true *)

(* A traducao de uma para outra, escrita como funcao. *)
fun paraNativa (Nihil : 'a Lizt) : 'a list = []
  | paraNativa (Kons (cabeca, cauda) : 'a Lizt) : 'a list =
        cabeca :: paraNativa cauda;
(* paraNativa numeros  =>  [4,6,0,2] *)

fun deNativa ([] : 'a list) : 'a Lizt = Nihil
  | deNativa (cabeca :: cauda : 'a list) : 'a Lizt =
        Kons (cabeca, deNativa cauda);
(* deNativa [1, 2, 3]  =>  Kons (1,Kons (2,Kons (3,Nihil))) *)

(* --- Tema 63: as mesmas funcoes, com a lista nativa ---------------------- *)

fun somaN ([] : int list) : int = 0
  | somaN (cabeca :: cauda : int list) : int = cabeca + somaN cauda;
(* somaN [4, 6, 0, 2]  =>  12 *)

fun mapN (f : 'a -> 'b) ([] : 'a list) : 'b list = []
  | mapN (f : 'a -> 'b) (cabeca :: cauda : 'a list) : 'b list =
        f cabeca :: mapN f cauda;
(* mapN (fn (x : int) => x * x) [1, 2, 3]  =>  [1,4,9] *)

fun filtrarN (p : 'a -> bool) ([] : 'a list) : 'a list = []
  | filtrarN (p : 'a -> bool) (cabeca :: cauda : 'a list) : 'a list =
        if p cabeca then cabeca :: filtrarN p cauda else filtrarN p cauda;
(* filtrarN (fn (x : int) => x > 2) [1, 2, 3, 4]  =>  [3,4] *)

(* --- Tema 64: a partir daqui, SEM anotacao: quem fala e a inferencia ----- *)

fun tamanho [] = 0
  | tamanho (_ :: cauda) = 1 + tamanho cauda;
(* val tamanho = fn : 'a list -> int *)

fun trocar (a, b) = (b, a);
(* val trocar = fn : 'a * 'b -> 'b * 'a *)

fun aplicarDuasVezes f x = f (f x);
(* val aplicarDuasVezes = fn : ('a -> 'a) -> 'a -> 'a *)

fun ultimo [x] = x
  | ultimo (_ :: cauda) = ultimo cauda
  | ultimo [] = raise Empty;
(* val ultimo = fn : 'a list -> 'a *)

fun contarIguais (alvo, l) = length (List.filter (fn x => x = alvo) l);
(* val contarIguais = fn : ''a * ''a list -> int *)

fun somaComAcumulador ([], acc) = acc
  | somaComAcumulador (x :: resto, acc) = somaComAcumulador (resto, x + acc);
(* val somaComAcumulador = fn : int list * int -> int
   Repare: ninguem escreveu "int" em lugar nenhum. O + entregou o tipo. *)
