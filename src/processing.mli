type col_type

module type BASIC = sig
  type 'a m

  val bind : 'a m -> ('a -> 'b m) -> 'b m

  val return : 'a -> 'a m
end

val read_csv : string -> string list
(** [read_csv path] reads csv file and puts each row into a list in string list format *)

val parse_csv : string -> string list * string list list
(** [parse_csv path] separates header with data and puts them in tuple format.*)

val transpose : 'a list list -> 'a list list
(** [transopose data] transposes the data.*)

val transpose_data : string -> string list list
(** [transopose_data path] parses and transposes the data.*)
