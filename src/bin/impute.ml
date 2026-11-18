
let impute data_filename vertex_filename edge_filename method_name =
  Printf.printf "unimplemented: impute %s %s %s %s\n"
    data_filename vertex_filename edge_filename method_name

open Cmdliner
open Cmdliner.Term.Syntax

let impute_cmd =
  let doc = "Impute missing data given the data file and the graph files" in
  Cmd.make (Cmd.info "impute" ~doc) @@
  let open Arg in
  let+ data_filename =
    let doc = "Data file should be a .csv file" in
    required & pos 0 (some' non_dir_file) None & info ["data-file-name"] ~docv:"DATAFILE" ~doc
  and+ vertex_filename =
    let doc = "A .csv file containing all vertices/variables in your graph" in
    required & pos 1 (some' non_dir_file) None & info ["vertex-file-name"] ~docv:"VERTEXFILE" ~doc
  and+ edge_filename =
    let doc = "A .csv file containing the adjacency matrix for your graph" in
    required & pos 2 (some' non_dir_file) None & info ["edge-file-name"] ~docv:"EDGEFILE" ~doc
  and+ method_name =
    let doc = "A string representing the imputation method." in
    required & pos 3 (some' string) None & info ["method-name"] ~docv:"METHOD" ~doc
  in
  impute data_filename vertex_filename edge_filename method_name

let cmd =
  Cmd.group (Cmd.info "ngrams.exe") @@
  [impute_cmd]

let () =
  exit (Cmd.eval cmd)
