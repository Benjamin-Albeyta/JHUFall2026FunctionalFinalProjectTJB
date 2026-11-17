(**
  A function f from XX to real number RR is a functor f from comparable XX to float.
  This is the input module to functor f.
*)
module type COMPARABLE = sig
  type t
  (** [t] is any type that can be compared. *)

  val compare : t -> t -> int
  (** [compare a b] is [-1] if [a] is less than [b], [1] if [a] is greater than
      [b], and [0] otherwise. *)
end
