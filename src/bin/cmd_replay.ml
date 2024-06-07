open Bos
open Ecma_sl
open Ecma_sl.Syntax.Result
module String = Astring.String

type options =
  { filename : Fpath.t
  ; workspace : Fpath.t
  }

let options filename workspace = { filename; workspace }
let node test witness = Cmd.(v "node" % p test % p witness)

type observable =
  | Stdout of string
  | File of string

let pp_effect fmt = function
  | Stdout str -> Format.fprintf fmt "(\"%s\" in stdout)" str
  | File f -> Format.fprintf fmt "(created file \"%s\")" f

let observable_effects = [ File "success"; Stdout "success"; Stdout "polluted" ]

let env testsuite =
  let ws = Unix.realpath @@ Fpath.to_string testsuite in
  let sharejs = List.hd Share.Location.nodejs in
  let node_path = Fmt.asprintf ".:%s:%s" ws sharejs in
  String.Map.of_list [ ("NODE_PATH", node_path) ]

let execute_witness ~env (test : Fpath.t) (witness : Fpath.t) =
  let open OS in
  Log.app "    running : %a" Fpath.pp witness;
  let cmd = node test witness in
  let+ (out, status) = Cmd.(run_out ~env ~err:err_run_out cmd |> out_string) in
  ( match status with
  | (_, `Exited 0) -> ()
  | (_, `Exited _) | (_, `Signaled _) ->
    Fmt.printf "unexpected node failure: %s" out );
  List.find_opt
    (fun effect ->
      match effect with
      | File file -> Sys.file_exists file
      | Stdout sub -> String.find_sub ~sub out |> Option.is_some )
    observable_effects

let payload_to_json (witness, effect) =
  `Assoc
    [ ("payload", `String (Fpath.to_string witness))
    ; ("effect", `String (Format.asprintf "%a" pp_effect effect))
    ]

let write_report ~workspace filename effectful_payloads =
  let mode = 0o666 in
  let json :> Yojson.t =
    `Assoc
      [ ("filename", `String (Fpath.to_string filename))
      ; ( "effectful_payloads"
        , `List (List.map payload_to_json effectful_payloads) )
      ]
  in
  let report_path = Fpath.(workspace / "confirmation.json") in
  OS.File.writef ~mode report_path "%a" (Yojson.pretty_print ~std:true) json

let replay filename workspace =
  Log.app "  replaying : %a..." Fpath.pp filename;
  let* testsuite = OS.Dir.must_exist Fpath.(workspace / "test-suite") in
  let env = env testsuite in
  let* witnesses = OS.Path.matches Fpath.(testsuite / "witness-$(n).js") in
  let* effectful_payloads =
    list_filter_map witnesses ~f:(fun witness ->
        let+ effect = execute_witness ~env filename witness in
        match effect with
        | Some (Stdout _ as effect) ->
          Log.app "     status : true %a" pp_effect effect;
          Some (witness, effect)
        | Some (File file as effect) ->
          ignore @@ OS.Path.delete (Fpath.v file);
          Log.app "     status : true %a" pp_effect effect;
          Some (witness, effect)
        | None ->
          Log.app "     status : false (no side effect)";
          None )
  in
  write_report ~workspace filename effectful_payloads

let main { filename; workspace } () =
  match replay filename workspace with
  | Error (`Msg msg) ->
    Log.log ~header:false "%s" msg;
    1
  | Ok () -> 0
