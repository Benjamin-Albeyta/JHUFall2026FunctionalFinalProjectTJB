module G : Graph.Sig.P with type V.t = string
(* A graph with string vertices *)


val csv_to_path : string -> (G.t, string) result
(** [csv_to_path path] loads a CSV file and converts it to a graph. *)