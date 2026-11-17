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
  type datum
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
    They are 2 different cpmf, so of different types !
    Don't know how to resolve yet, assume they are of the same type for now
  *)

  val model : g -> t
  (** [model gg] returns the map: vertex to dag_factor, represented by the dag [gg]. *)

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