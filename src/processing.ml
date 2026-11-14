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

module type BASIC = sig
  type 'a m

  val bind : 'a m -> ('a -> 'b m) -> 'b m

  val return : 'a -> 'a m
end

(* monad with bind and return *)
module ResultM : BASIC with type 'a m = ('a, string) result = struct 
  type 'a m = ('a, string) result
  let bind m f = 
    match m with
    | Error m -> Error m
    | Ok x -> f x 
  let return (x : 'a): ('a, string) result = Ok x
end

(* 
type col_type = 
  | IntColumn of int list
  | FloatColumn of float list
  | BoolColumn of bool list
  | StringColumn of string list *)


type cell_type = 
  | IntCell of int option
  | FloatCell of float option
  | BoolCell of bool option
  | StringCell of string option

let is_missing s =
  match String.trim s with
  | "" | "NA" | "N/a" | "N/A" |"null" -> true
  | _ -> false

(* Rows as string because each column has a different data type. *)
(* let read_csv path = 
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
  transpose data  *)

let split line = String.split_on_char ',' line

let rec collect_columns ic ncols lineno cols =
  match In_channel.input_line ic with
  | None -> Ok (List.map List.rev cols)
  | Some "" -> collect_columns ic ncols (lineno + 1) cols
  | Some line ->
    let fields = split line in
    if List.length fields <> ncols then
      Error (Printf.sprintf "line %d: expected %d fields" lineno ncols)
    else
      collect_columns ic ncols (lineno + 1)
        (List.map2 (fun col field -> field :: col) cols fields)

let read_columns path =
  In_channel.with_open_text path (fun ic ->
    match In_channel.input_line ic with
    | None -> Error "Empty CSV, No Header"
    | Some header ->
      let headers = split header in
      let ncols = List.length headers in
      ResultM.bind
        (collect_columns ic ncols 2 (List.init ncols (fun _ -> [])))
        (fun cols -> ResultM.return (headers, cols))  
  )

(* let check_type f col = List.for_all (fun elt -> f elt <> None) col *)
let check_type f col = List.for_all (fun elt -> is_missing elt || f elt <> None) col

(* Each column needs to have a consistent type. *)
(* let check_column i col = 
  if check_type int_of_string_opt col then
    Ok (IntColumn (List.map int_of_string col))
  else if check_type bool_of_string_opt col then 
    Ok (BoolColumn (List.map bool_of_string col))
  else if check_type float_of_string_opt col then 
    Ok (FloatColumn (List.map float_of_string col))
  (* for string column case *)
  else 
    Ok (StringColumn col) *)
let parse wrap f col =
  Iarray.of_list (List.map (fun s -> wrap (if is_missing s then None else f s)) col)
let infer_column i col = 
  if List.for_all is_missing col then
    Error (Printf.sprintf "column %d has only missing values" i)
  else if check_type int_of_string_opt col then
    Ok (parse (fun v -> IntCell v) int_of_string_opt col)
  else if check_type bool_of_string_opt col then 
    Ok (parse (fun v -> BoolCell v) bool_of_string_opt col)
  else if check_type float_of_string_opt col then 
    Ok (parse (fun v -> FloatCell v) float_of_string_opt col)
  (* for string column case *)
  else 
    Ok (parse (fun v -> StringCell v) (fun s -> Some s) col)
  

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

(* let typed_columns path = 
  let headers, data = parse_csv path in
  let cols = transpose data in
  get_columns check_column cols  *)

let rows_of_columns cols =
  let nrows = 
    if Iarray.length cols = 0 
      then 0
    else Iarray.length (Iarray.get cols 0) 
  in
  Iarray.init nrows 
    (fun i -> Iarray.map 
      (fun col -> Iarray.get col i) cols)

let typed_columns path = 
  ResultM.bind (read_columns path) (fun (headers, cols) ->
    ResultM.bind (get_columns infer_column cols) (fun typed ->
      let columns = Iarray.of_list typed in
      ResultM.return (Iarray.of_list headers, columns, rows_of_columns columns)
    )
  )

let test path = 
  match typed_columns path with
  | Ok (headers, cols, rows) -> Ok rows
  |Error e -> Error e

let is_present = function
  | IntCell None | FloatCell None | BoolCell None | StringCell None -> false
  | _ -> true

let present_mask rows = Iarray.map (Iarray.map is_present) rows  

let mask path =
  ResultM.bind (typed_columns path) 
  (fun (_, _, rows) ->
    ResultM.return (present_mask rows))

module BoolArrayMap = Map.Make (struct
    type t = bool iarray
    let compare = compare
  end
)
let group_by_key keys = 
  let _, groups = 
    Iarray.fold_left 
      (fun (i, m) key -> 
        match BoolArrayMap.find_opt key m with
        | None -> (i + 1, BoolArrayMap.add key [i] m)
        | Some indices -> (i + 1, BoolArrayMap.add key (i :: indices) m)
      )
    (0, BoolArrayMap.empty)
    keys
  in
  BoolArrayMap.map List.rev groups

let key_mapping path = 
  ResultM.bind (mask path) (fun keys ->
    ResultM.return (BoolArrayMap.bindings (group_by_key keys))
  )
  
  


