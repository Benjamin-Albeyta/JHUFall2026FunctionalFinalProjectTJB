(* Basic Module Signature *)
module type BASIC = sig
  type 'a m
  val bind : 'a m -> ('a -> 'b m) -> 'b m
  val return : 'a -> 'a m
end

(* Monad with bind and return for the Result type*)
module ResultM : BASIC with type 'a m = ('a, string) result = struct 
  type 'a m = ('a, string) result
  let bind m f = 
    match m with
    | Error m -> Error m
    | Ok x -> f x 
  let return (x : 'a): ('a, string) result = Ok x
end
let ( let* ) = ResultM.bind

module Cell = struct
  (* Created a type for a cell, 4 different kinds in this type, each with option. 
  This way, either iarray or list can this in as a type even with different kinds.l*)
  type t = 
    | IntCell of int option
    | FloatCell of float option
    | BoolCell of bool option
    | StringCell of string option
  (* If value is missing in a cell, return true *)
  let is_missing s =
    match String.lowercase_ascii (String.trim s) with
    | "" | "na" | "n/a" | "null" -> true
    | _ -> false
  (* For mapping of bool list, check if Cell is None or not, None means False *)
  let is_present = function
    | IntCell None | FloatCell None | BoolCell None | StringCell None -> false
    | _ -> true
  
  (* Returns true if every non-missing value parses *)
  let check_consistent_parse f col = 
    List.for_all (fun elt -> is_missing elt || Option.is_some (f elt)) col

  (* Passes in two functions: wrap function to wrap with cell type kind and 
  another to convert from string to type opt to immutable array *)
  let parse wrap f col =
    Iarray.of_list (List.map (fun s -> wrap (if is_missing s then None else f s)) col)

  (* Infer the type of a column based on its values using the standard library functions. *)
  let infer_column i col = 
    if List.for_all is_missing col then
      Error (Printf.sprintf "column %d has only missing values" i)
    else if check_consistent_parse int_of_string_opt col then
      Ok (parse (fun v -> IntCell v) int_of_string_opt col)
    else if check_consistent_parse bool_of_string_opt col then 
      Ok (parse (fun v -> BoolCell v) bool_of_string_opt col)
    else if check_consistent_parse float_of_string_opt col then 
      Ok (parse (fun v -> FloatCell v) float_of_string_opt col)
    (* for string column case *)
    else 
      Ok (parse (fun v -> StringCell v) (fun s -> Some s) col)

  (* in Cell to _string*)
  let to_string = function
    | IntCell (Some n) -> string_of_int n
    | FloatCell (Some f) -> string_of_float f
    | BoolCell (Some b) -> string_of_bool b
    | StringCell (Some s) -> s
    | IntCell None | FloatCell None | BoolCell None | StringCell None -> ""
end

module Csv = struct
    (* Split the line of csv file with 'c' *)
  let split line = List.map String.trim (String.split_on_char ',' line)
  (* Collect columns called from read_columns. 
  Raises error when the items sepratated by comma in a row 
  doesn't match with the number of columns*)
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
  (* Raises when the CSV is empty, read columns by calling collect_columns *)
  let read_columns path =
    try
      In_channel.with_open_text path (fun ic ->
        match In_channel.input_line ic with
        | None -> Error "Empty CSV, No Header"
        | Some header ->
          let headers = split header in
          let ncols = List.length headers in
          (* Here, this checks any error from collect_columns *)
          let* cols = 
            (collect_columns ic ncols 2 (List.init ncols (fun _ -> []))) 
            in
            ResultM.return (headers, cols)  
      )
    with 
      Sys_error msg -> Error msg
end

module Table = struct
  type t = {
    headers : string iarray;
    columns : Cell.t iarray iarray;
    rows : Cell.t iarray iarray;
  }
  
  (* Use infer_column to return the typed columns *)
  let get_columns f cols=
    ResultM.bind  
      ((List.fold_left 
        (fun acc col -> 
          let* ys, i = acc in 
          let* y = f i col in 
          ResultM.return (y :: ys, i + 1)
        )
      )
      (ResultM.return ([], 0)) cols)
      (fun (ys, _) -> ResultM.return (List.rev ys))
  
  (* Transpose columns in iarray *)
  let rows_of_columns cols =
    let nrows = 
      if Iarray.length cols = 0 
        then 0
      else Iarray.length (Iarray.get cols 0) 
    in
    Iarray.init nrows 
      (fun i -> Iarray.map 
        (fun col -> Iarray.get col i) cols)

  (* Load table of typed headers, columns, and rows *)
  let load path = 
    (* Check if read_columns return Ok or Error *)
    let* (headers, cols) = Csv.read_columns path in
    let* typed_cols = get_columns Cell.infer_column cols in
    let columns = Iarray.of_list typed_cols in
    ResultM.return {headers = Iarray.of_list headers; columns; rows = rows_of_columns columns}

  (* Convert table to CSV string *)
  let to_csv (t : t) = 
    let header_line = String.concat "," (Iarray.to_list t.headers) in
    let row_lines = 
      Iarray.to_list 
        (Iarray.map (fun row -> String.concat "," 
          (Iarray.to_list 
            (Iarray.map Cell.to_string row))) 
        t.rows)
    in
    String.concat "\n" (header_line :: row_lines)

  (* Save table to a CSV file *)
  let save (path : string) (t : t) =
    let csv_string = to_csv t ^ "\n" in
    try
      Out_channel.with_open_text path (fun oc ->
        Out_channel.output_string oc csv_string;
        Ok ())
    with Sys_error msg -> Error msg

  (* Convert table to a string representation *)
  let table_to_string (t : t) = 
     ( t.headers,
      Iarray.map (Iarray.map Cell.to_string) t.columns,
      Iarray.map (Iarray.map Cell.to_string) t.rows )
  
  (* Extract table from result *)
  let extract_table result_table =
    match result_table with
    | Ok t -> t
    | Error e -> failwith e

  let column_types (t : t) =
    let row = Iarray.get t.rows 0 in
    Iarray.map (fun s -> 
      match s with 
      | Cell.StringCell _ -> "String"
      | Cell.IntCell _ -> "Int"
      | Cell.BoolCell _ -> "Bool"
      | Cell.FloatCell _ -> "Float") 
      row

end

module Grouping = struct
  (* Create a map from bool iarrays *)
  module BoolArrayMap = Map.Make (struct
      type t = bool iarray
      let compare = compare
  end)

  (* Return a mask of the same shape as the input, where each element is true if the corresponding cell is present, 
  and false otherwise. *)
  let present_mask rows = Iarray.map (Iarray.map Cell.is_present) rows  

  (* Group rows by a key *)
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

  (* let of_table (t : Table.t) = group_by_key (present_mask t.rows) *)
  (* let mapping_of_table (t : Table.t) = BoolArrayMap.bindings (group_by_key (present_mask t.rows)) *)
  (* Group rows by a key *)
  let mapping_of_table (t : Table.t) = group_by_key (present_mask t.rows)
  (* Create a mapping from a file path *)
  let mapping_of_path path = 
    let* table = Table.load path in
    ResultM.return (mapping_of_table table)
end




  
  


