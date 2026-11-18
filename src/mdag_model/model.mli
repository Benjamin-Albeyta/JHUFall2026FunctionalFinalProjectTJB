open Sig
open Cpmf
open Dag

(**
  The statistical model relative to an m-DAG, with DAG factorization.
*)
module type DF = sig

  type x
  (** Type of the X(1) variable represented by vertex *)
  type r
  (** Type of the R variable represented by vertex *)
  type v
  (** Variant type of variable represented by vertex *)
  type g
  (** Type of the m-DAG graph *)
  type datum = { x1 : x ; x2 : x ; x3 : x 
               ; r1 : r ; r2 : r ; r3 : r }
  (** A row of data *)
  type data = datum list
  (** A table of data *)

  type t
  (** Type of a [dag_model] is just a map from vertex to cpmf *)

  type cpmf
  (** Type of the cpmf *)
  val dag_factor : v -> g -> cpmf
  (**
    [dag_factor v g] returns the cpmf p(v | parents of v in g).
    Example: graph G is A -> B -> C <- A.
    [dag_factor C G] gives the cpmf representing p(C | A, B).
    [dag_factor B G] gives the cpmf representing p(B | A).
    [dag_factor A G] gives the cpmf representing p(A).
    They are cpmf of different types !
    Don't know how to resolve yet, assume they are of the same type for now
  *)

  val model : g -> t
  (**
    [model gg] returns the map: vertex to dag_factor, represented by the dag [gg].
    The values of the dag_factor are initialized randomly.
    Example:
      A is mapped to p(A),
      B is mapped to p(B | A),
      C is mapped to p(C | A, B).
    Given a data point (A=a, B=b, C=c), these cmpfs can be used to compute the probability
    p(A=a, B=b, C=c).
  *)

  val fit : data -> g -> t
  (** [fit dd gg] returns the MLE estimate [p] of the model associated with the graph [gg] *)

  val sample : int -> t -> data
  (** [sample n p] returns a data [d] of length [n] by sampling from the given model [p]. *)

  val csample : v list -> int -> t -> data
  (** [csample vv n p] returns a data [d] of length [n] by sampling from the given model [p],
  conditioning on the given values [vv]. *)
end

(**
  [MAKEDF] is a functor that turn a module of X(1) variables and a module of R variables
  to the module of DAG model over {X(1), R}, with the PM factorization.
*)
module type MAKEDF = functor (Xx : COMPARABLE) (Rr : COMPARABLE) -> DF

module MakeDF : MAKEDF

(**
  The statistical model relative to an m-DAG, with pattern-mixture factorization.
*)
module type PM = sig

  type x
  (** Type of the X(1) variable represented by vertex *)
  type r
  (** Type of the R variable represented by vertex *)
  type v
  (** Variant type of variable represented by vertex *)
  type pat = { r1 : r ; r2 : r ; r3 : r }
  (** Type of a pattern, which is just an ordered tuple *)
  type g
  (** Type of the m-DAG graph *)
  type pg
  (** Type of the pattern graph *)
  type datum = { x1 : x ; x2 : x ; x3 : x 
               ; r1 : r ; r2 : r ; r3 : r }
  (** A row of data *)
  type data = datum list
  (** A table of data *)

  type t
  (** Type of a [dag_model] is just a map from vertex to cpmf *)

  type cpmf
  (** Type of the cpmf *)

  val pattern_dag : g -> pg
  (**
    [pattern_dag g pg] construct a pattern graph [pg] from [g].
    Example: graph G X -> Y -> Rx <- Ry has pattern graph
              (1,1)
              /   \
          (0,1)   (1,0)
              \   /
              (0,0)
  *)

  val gibbs : v -> g -> cpmf
  (**
    [gibbs v g] returns the cpmf p(v | markov blanket of v in g).
    Example: graph G X -> Y -> Rx <- Ry.
    [gibbs Rx G] gives the cpmf representing p(Rx | Y, Ry).
  *)

  val model : g -> t
  (**
    [model gg] returns the map: vertex to gibbs, represented by the dag [gg].
  *)

  val fit_gibbs : data -> pg -> v -> t -> t
  (**
    [fit_gibbs var pat m dd patg] returns a new [m'] such that the gibbs factor corresponding to
    vertex [var] under pattern [pat] in the original model [m], using the supplied data and the pattern graph.
  *)

  val fit : data -> pg -> g -> t
  (**
    [fit dd gg] returns the MLE estimate [p] of the model associated with the graph [gg].
    This entails calling [fit_gibbs] and invoke Gibbs sampling.
  *)

  val sample : int -> t -> data
  (** [sample n p] returns a data [d] of length [n] by sampling from the given model [p]. *)

  val csample : v list -> int -> t -> data
  (** [csample vv n p] returns a data [d] of length [n] by sampling from the given model [p],
  conditioning on the given values [vv]. *)
end

(**
  [MAKEDF] is a functor that turn a module of X(1) variables and a module of R variables
  to the module of DAG model over {X(1), R}, with the PM factorization.
*)
module type MAKEPM = functor (Xx : COMPARABLE) (Rr : COMPARABLE) -> PM

module MakePM : MAKEPM