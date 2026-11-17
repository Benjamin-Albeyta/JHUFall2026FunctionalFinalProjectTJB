open Graph
open Sig

module type EDGE = sig
  type t = int * int
  val compare : t -> t -> int
end
module type VERTEX = sig
  type t = int
  val compare : t -> t -> int
end

module type S = sig
  include EDGE
  include VERTEX

  type t
  type vertex

  val dseparation : vertex list -> vertex list -> vertex list -> t -> bool
  (** [dseparation A B C g] returns [true] if subsets A and B are d-separated in the graph G,
    otherwise [false] *)

  val pa : vertex -> t -> vertex list
  (** [pa a g] returns the list of parents of [a] in the graph [g] *)

  val ch : vertex -> t -> vertex list
  (** [ch a g] returns the list of parents of [a] in the graph [g] *)

  val mb : vertex -> t -> vertex list
  (** [mb a g] returns the list of vertices comprise the markov blanket of [a] in the graph [g] *)

end

module type MAKE = functor (V: VERTEX) (G: EDGE) -> S

module Make : MAKE