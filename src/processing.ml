(* opam install nx; opam install talon *)
(* To use at utop, 
  #require "nx.c";; 
  #require "nx";; 
  #require "talon";; 
  #require "talon.csv";;
  let df = Talon_csv.read "data_test.csv";;
  let df = Talon_csv.of_string "a,b\n1,2\n3,4";;
  (* to get column names *)
  Talon.column_names df;; 

  (* To overwrite default *)
  (* let df =
  Talon_csv.read
    ~names:["id"; "price"; "label"]
    ~dtype_spec:[("id", `Int64); ("price", `Float64)]
    "data.csv";; *)

*)
(* To test individual functions at utop
dune utop
#use "src/processing.ml";; 
read_csv "data.csv"

After update, run #use "src/processing.ml";; again to see new change
*)

(* type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e *)


type col_type = 
  | IntColumn of int list
  | FloatColumn of float list
  | BoolColumn of bool list
  | StringColumn of string list



(* Rows as string because each column has a different data type. *)
let read_csv path = 
  In_channel.with_open_text path In_channel.input_all
  |> String.split_on_char '\n'
  |> List.filter (fun list -> list <> "")
  |> List.map (fun elt -> String.split_on_char ',' elt)

let parse_csv path =
  let rows = read_csv path in
  match rows with 
  | [] -> failwith "Empty CSV"
  | hd :: tl -> (hd, tl)

let rec transpose = function
  | [] -> []
  | [] :: _ -> []
  | rows -> List.map List.hd rows :: transpose (List.map List.tl rows)

let transpose_data path =
  let headers, data = parse_csv path in
  transpose data 

(* monad with bind and return *)
module ResultM = struct 
  type 'a m = ('a, string) result
  let bind m f = 
    match m with
    | Error m -> Error m
    | Ok x -> f x 
  let return (x : 'a): ('a, string) result = Ok x
end

let check_type f col = List.for_all (fun elt -> f elt <> None) col

(* Each column needs to have a consistent type. *)
let check_column i col = 
  if check_type int_of_string_opt col then
    Ok (IntColumn (List.map int_of_string col))
  else if check_type bool_of_string_opt col then 
    Ok (BoolColumn (List.map bool_of_string col))
  else if check_type float_of_string_opt col then 
    Ok (FloatColumn (List.map float_of_string col))
  (* for string column case *)
  else if check_type (fun x -> Some x) col then 
    Ok (StringColumn col)
  else 
    Error (Printf.sprintf "column %d has no consistent type" i)

let get_columns f cols=
  ResultM.bind  
    (List.fold_left 
      (fun acc col -> 
        ResultM.bind acc (fun (ys, i) -> 
          ResultM.bind (f i col) (fun y ->
            ResultM.return (y :: ys, i + 1)
          ) 
        )
      )
    (ResultM.return ([], 0))
    cols)
    (fun (ys, _) -> ResultM.return (List.rev ys))

let typed_columns path = 
  let headers, data = parse_csv path in
  let cols = transpose data in
  get_columns check_column cols


  


