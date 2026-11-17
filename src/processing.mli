(* Basic monad operations *)
module type BASIC = sig
  type 'a m
  val bind : 'a m -> ('a -> 'b m) -> 'b m
  val return : 'a -> 'a m
end

(* Result monad *)
module ResultM : BASIC with type 'a m = ('a, string) result

(* The let* operator for the Result monad *)
val ( let* ) :
  ('a, string) result -> ('a -> ('b, string) result) -> ('b, string) result

(* Cell operations *)
module Cell : sig
  type t =
    | IntCell of int option
    | FloatCell of float option
    | BoolCell of bool option
    | StringCell of string option

  val is_missing : string -> bool
  val is_present : t -> bool
  val infer_column : int -> string list -> (t iarray, string) result
  val to_string : t -> string
end

(* CSV operations *)
module Csv : sig
  val read_columns :
    string -> (string list * string list list, string) result
end

(* Table operations *)
module Table : sig
  type t = {
    headers : string iarray;
    columns : Cell.t iarray iarray;
    rows : Cell.t iarray iarray;
  }
  val get_columns :
    (int -> 'a -> ('b, string) result) -> 'a list -> ('b list, string) result
  val load : string -> (t, string) result
  val to_csv : t -> string
  val save : string -> t -> (unit, string) result
  val table_to_string :
    t -> string iarray * string iarray iarray * string iarray iarray
  val extract_table : (t, string) result -> t
end

(* Grouping operations *)
module Grouping : sig
  module BoolArrayMap : Map.S with type key = bool iarray

  val present_mask : Cell.t iarray iarray -> bool iarray iarray
  val group_by_key : bool iarray iarray -> int list BoolArrayMap.t
  val mapping_of_table : Table.t -> (bool iarray * int list) list
  val mapping_of_path : string -> ((bool iarray * int list) list, string) result
end