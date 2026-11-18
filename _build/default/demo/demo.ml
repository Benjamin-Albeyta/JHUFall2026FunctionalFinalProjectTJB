(* opam install ocamlgraph *)

(* #require "ocamlgraph";; *)
(* #use "demo/demo.ml";; *)


open Graph

module G = Graph.Imperative.Digraph.Concrete(struct
  type t = string
  let compare = compare
  let hash = Hashtbl.hash
  let equal = (=)
end)

let () =
  let g = G.create () in

  G.add_vertex g "a";
  G.add_vertex g "b";
  G.add_vertex g "c";

  G.add_edge g "a" "b";  (* a -> b *)
  G.add_edge g "b" "c";  (* b -> c *)

  Printf.printf "%b\n" (G.mem_edge g "a" "b"); (* true *)
  Printf.printf "%b\n" (G.mem_edge g "b" "a") (* false *)

let csv_to_graph path = 
  match Processing.Csv.read_columns path with 
  | Error msg -> Error msg
  | Ok (_, src :: dst :: _) ->   
      let g = G.create () in
      List.iter2 (fun a b -> 
        if not (Processing.Cell.is_missing a || Processing.Cell.is_missing b) then
          G.add_edge g a b) 
      src dst;
      Ok g
  | Ok _ -> Error "need at least two columns"