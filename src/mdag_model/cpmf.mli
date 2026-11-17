(*
  --------
  OVERVIEW
  --------

  Let X, Y be categorical variables taking values in finite sets XX and YY, resp.
  A conditional probability mass function (CPMF) is a function `p: (XX, YY) -> float`
  sending a pair values (x, y) to a real number in [0, 1], denoted p(y | x).
  This number is interpreted as:
  'p(y | x) is the chance of Y = y given the fact that X = x'.
  The CPMF is generally denoted p(Y | X).

  There are 2 constraints for any CPMF p(Y | X), called probability constraints
  1. p(y | x) >= 0 for all values (x, y).
  2. \sum_{y in YY} p(y | x) = 1 for all values x.

  This module is an implementation of the CPMF map when the sets XX and YY are finite.
  In particular, CPMF is just a dictionary from keys being values in XX
  to PMF over YY.
*)

open Sig

(**
  Output signature of the functor Make(X, Y).
  This is the module of all finite and non-negative functions 
  on some finite and comparable set Yy, indexed by a finite and comparable set Xx.
  Mathematically, this is the module for all point mass measures on Yy,
  conditioned on Xx.
*)
module type S = sig
  type kx
  (** Type of the conditioning input data XX. *)

  type ky
  (** Type of the input data YY. *)

  type t
  (** [float] is the type of the output data f(y | x). [t] is the type of conditional maps f(. | .). *)

  val zero : t
  (** [zero] is a zero function mapping all key pairs to zero function. *)

  val add : kx -> ky -> float -> t -> t
  (** [add x y v f] returns a new map [f'] which is similar to [f], but [f'(y | x) = v]. *)

  val eval : kx -> ky -> t -> float
  (** [eval x y f] is the output of f(y | x), with f is a cmap, x, y are input. *)

  val remove : kx -> ky -> t -> t
  (** [remove x y f] returns a new map [f'] which is similar to [f], but [f'(y | x) = 0]. *)

  val to_cpmf : t -> t option
  (**
  If [f] is a non-negative map, [to_cpmf f] returns the normalization of [f],
  which is a cpmf map [Some f'], such that the sum of [f'(y | x)] over all keys [y] is [1],
  for all conditional value [x].
  Otherwise, [to_cpmf f] returns [None].
  *)

  val sample : int -> kx -> t -> ky list
  (** [sample n x f] returns a list of data obtained by sampling from the pmf f(Y | x). *)
end

module type MAKE = functor (Xx : COMPARABLE) (Yy : COMPARABLE) -> S with
  type kx = Xx.t and
  type ky = Yy.t

module Make : MAKE