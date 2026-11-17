(**
  --------
  OVERVIEW
  --------

  Let X be categorical variables taking values in finite sets XX.
  A probability mass function (PMF) is a function `p: XX -> float`
  sending a value x to a real positive number in [0, 1], denoted p(x).
  This number is interpreted as: 'p(x) is the chance of X = x'.
  The PMF is generally denoted p(X), called a pmf over XX.

  There are 2 constraints for any PMF p(X), called probability constraints
  1. p(x) >= 0 for all values x.
  2. \sum_{x in XX} p(x) = 1.

  This module is an implementation of the PMF map when the sets XX is finite.
  A naive and clunky data structure for p(X) is a vector V of dimensions `XX`,
  where the x-element V_{x} = p(X=x).
  This supports a wide range of linear algebra operations.
  However, we don't need that here.
  All we need is to look up the value p(x), modify p(X), and sample from p(X).
  This can be done using a `Map`.
  [Module Map](https://ocaml.org/manual/5.5/api/Map.html)
*)

open Sig

(**
  Output signature of the functor Make(Xx).
  This is the module of all finite and non-negative functions 
  on some finite and comparable set Xx. Mathematically, this is the module
  for all point mass measures on Xx.
*)
module type S = sig
  type key
  (** Type of the input data. *)

  type t
  (** [float] is the type of the output data. [t] is the type of maps on X. *)

  val zero : t
  (** [zero] is a zero function mapping all keys to zero number. *)

  val eval : key -> t -> float
  (** [eval x f] is the output of f(x), with f is a map and x is an input. *)

  val add : key -> float -> t -> t
  (** [add x y f] returns a new map [f'] which is similar to [f], but [f'(x) = y]. *)

  val remove : key -> t -> t
  (** [remove x f] returns a new map [f'] which is similar to [f], but [f'(x) = 0]. *)

  val to_pmf : t -> t option
  (**
  If [f] is a non-negative map, [to_pmf f] returns the normalization of [f],
  which is a pmf map [Some f'], such that the sum of [f'(x)] over all keys [x] is [1].
  Otherwise, [to_pmf f] returns [None].
  *)

  val sample : int -> t -> key list
  (** [sample n f] returns a list of data obtained by sampling from the pmf f. *)
end

module type MAKE = functor (Xx : COMPARABLE) -> S with type key = Xx.t

module Make : MAKE