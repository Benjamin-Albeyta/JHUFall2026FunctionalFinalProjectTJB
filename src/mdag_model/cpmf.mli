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
  Output signature of the functor Make(Xx)(Yy).
*)
module type S = sig

  type x
  (** Type of the input x in Xx. *)
  type y
  (** Type of the input y in Yy. *)
  type fy
  (** [fy] is the type of any function f(y) defined on Y. *)
  type fyx
  (** [fyx] is the type of any function f(y | x) defined on Y and indexed by X. *)

  type t
  (** [t] is the type of non-negative functions f(y | x) defined on Y and indexed by X. *)

  val zero : t
  (** Is the zero function on Y for all x. That is, zero(y | x) = 0 for all y, x *)

  val update : (float -> float) -> x -> y -> fyx -> fyx
  (**
    [update g x y f] returns a new map [f'] which is similar to [f], but
    the value [z = f(y | x)] is replaced by [g(z)].
  *)

  val trim : fyx -> t
  (**
    [trim f] returns new function [f'] with all negative outputs replaced by zero.
    That is, f'(. | x) is the trimmed version of f(. | x), for all x.
  *)

  val eval : x -> y -> t -> float
  (** [eval x y f] is the value of f(y | x). *)

  val normalize : t -> t
  (**
    [normalize f] returns the normalized function [f'] of a non-negative function [f].
    That is, for all x, f'(. | x) is the normalized pmf of f(. | x).
  *)

  val support : x -> t -> y list
  (** [support f] returns the support of a non-negative function f(. | x).
  The support of f(. | x) is defined as the set of values of Y for which f(y | x) > 0. *)

  val csample : int -> x -> t -> y list
  (**
    [sample n x f] returns a list of [n] elements sampled from the pmf f(. | x).
    By definition, this list only contain values in the support of f(. | x).
  *)
end

module type MAKE = functor (Xx : COMPARABLE) (Yy : COMPARABLE) -> S with
  type x = Xx.t and
  type y = Yy.t

module Make : MAKE