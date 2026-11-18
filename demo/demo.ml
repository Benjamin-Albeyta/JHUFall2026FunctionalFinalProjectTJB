(* opam install ocamlgraph *)

(* #require "ocamlgraph";; *)


(* #use "demo/demo.ml";;
  let result = csv_to_graph "demo.csv";;
  match result with
  | Ok g -> Printf.printf "%b\n" (G.mem_edge g "shirt" "tie")
  | Error msg -> prerr_endline msg;; *)

open Graph

module G = Graph.Persistent.Digraph.Concrete(struct
  type t = string
  let compare = compare
  let hash = Hashtbl.hash
  let equal = (=)
end)

let () =
  let g = G.empty in

  let g = G.add_vertex g "a" in
  let g = G.add_vertex g "b" in
  let g = G.add_vertex g "c" in

  let g = G.add_edge g "a" "b" in  (* a -> b *)
  let g = G.add_edge g "b" "c" in  (* b -> c *)

  Printf.printf "%b\n" (G.mem_edge g "a" "b"); (* true *)
  Printf.printf "%b\n" (G.mem_edge g "b" "a") (* false *)

let csv_to_graph path = 
  match Processing.Csv.read_columns path with 
  | Error msg -> Error msg
  | Ok (_, src :: dst :: _) ->   
    Ok (
      List.fold_left2 (fun g a b -> 
        if Processing.Cell.is_missing a || Processing.Cell.is_missing b 
          then g
        else 
          G.add_edge g a b
      ) G.empty src dst)
  | Ok _ -> Error "need at least two columns"


