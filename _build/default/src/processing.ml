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

let read_csv path = 
  In_channel.with_open_text path In_channel.input_all
  |> String.split_on_char '\n'