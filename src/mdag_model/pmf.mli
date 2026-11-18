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
  1. (Non-negative) p(x) >= 0 for all values x.
  2. (Normalized) \sum_{x in XX} p(x) = 1.

  This module is an implementation of the PMF map when the sets XX is finite.

  Input module [X] is a COMPARABLE, like Int, Str, etc, associated with the input X.
  Output module [S] is a set of operations applying on any non-negative function over X.
  The type [S.t] of the output module is the type of a non-negative function over X.
  Implementation is done with [Map](https://ocaml.org/manual/5.5/api/Map.html).

  -------------
  KEY FUNCTIONS
  -------------

  - [normalize f] returns the normalized function [f'] of a non-negative function [f].
  - [sample n f] returns a list of [n] elements sampled from the pmf [f].
*)
open Sig

(**
  Output signature of the functor Make(Xx).
*)
module type S = sig

  type x
  (** Type of the input x in Xx. *)

  type t
  (** [t] is the type of any function f(x) defined on X. *)

  val zero : t
  (** [zero] is a zero function mapping all keys to zero number. *)

  val update : (float -> float) -> x -> t -> t
  (**
    [update g x f] returns a new map [f'] which is similar to [f], but
    the value [y] mapped to [x] is replaced by [g(y)].
  *)

  val trim : t -> t
  (** [trim f] returns new function [f'] on X with all negative outputs replaced by zero. *)

  val eval : x -> t -> float
  (** [eval x f] is the output of f(x), with f is a map and x is an input. *)

  val normalize : t -> t
  (**
    [normalize f] returns the normalized function [f'] of a non-negative function [f].
  *)

  val support : t -> x list
  (** [support f] returns the support of a non-negative function [f].
  The support of [f] is defined as the set of values of X for which f(x) > 0. *)

  val sample : int -> t -> x list
  (**
    [sample n f] returns a list of [n] elements sampled from the pmf [f].
    By definition, this list only contain values in the support of f.
  *)
end

module type MAKE = functor (Xx : COMPARABLE) -> S with type x = Xx.t

module Make : MAKE