open Bos
open Ecma_sl
open Smtml.Syntax.Result
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
  | File_access of Fpath.t
  | Error of string

let pp_effect fmt = function
  | Stdout str -> Format.fprintf fmt "(\"%s\" in stdout)" str
  | File f -> Format.fprintf fmt "(created file \"%s\")" f
  | File_access _ -> Format.fprintf fmt "(undesired file access occurred)"
  | Error str -> Format.fprintf fmt "(threw Error(\"%s\"))" str

let default_effects =
  [ File "success"; Stdout "success"; Error "I pollute."; Stdout "polluted" ]

let env testsuite =
  let ws = Unix.realpath @@ Fpath.to_string testsuite in
  let sharejs = List.hd Explode_js.Sites.Share.nodejs in
  let node_path = OS.Env.opt_var "NODE_PATH" ~absent:"" in
  let node_path = Fmt.asprintf "%s:.:%s:%s" node_path ws sharejs in
  String.Map.of_list [ ("NODE_PATH", node_path) ]

let with_effects f =
  (* Don't care if these file operations fail *)
  let exploit_file = Fpath.(v "./exploited") in
  let _ = OS.File.write exploit_file "success\n" in
  let result = f (File_access exploit_file :: default_effects) in
  let _ = OS.File.delete exploit_file in
  result

let execute_witness ~env (test : Fpath.t) (witness : Fpath.t) =
  let open OS in
  with_effects (fun observable_effects ->
      Logs.app (fun m -> m "    running : %a" Fpath.pp witness);
      let cmd = node test witness in
      let+ out, status =
        Cmd.(run_out ~env ~err:err_run_out cmd |> out_string)
      in
      ( match status with
      | _, `Exited 0 -> ()
      | _, `Exited _ | _, `Signaled _ ->
        Fmt.printf "unexpected node failure: %s" out );
      List.find_opt
        (fun effect ->
          match effect with
          | Stdout sub -> String.find_sub ~sub out |> Option.is_some
          | File file -> Sys.file_exists file
          | File_access file ->
            let stats = Unix.stat (Fpath.to_string file) in
            stats.Unix.st_atime > stats.Unix.st_ctime
          | Error str ->
            let sub = Format.sprintf "Error: %s" str in
            String.find_sub ~sub out |> Option.is_some )
        observable_effects )

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

let replay ?original_file ?taint_summary filename workspace =
  Logs.app (fun m -> m "  replaying : %a..." Fpath.pp filename);
  let* testsuite = OS.Dir.must_exist Fpath.(workspace / "test-suite") in
  let env = env testsuite in
  let* witnesses = OS.Path.matches Fpath.(testsuite / "witness-$(n).json") in
  let* effectful_payloads =
    list_filter_map
      (fun witness ->
        ( match taint_summary with
        | Some taint_summary ->
          let output = Fpath.(workspace / "literal") in
          let output = Fpath.to_string output in
          let witness = Fpath.to_string witness in
          let _ =
            I2.Run.literal ~mode:0o666 ?file:original_file taint_summary witness
              output
          in
          ()
        | None -> () );
        let+ effect = execute_witness ~env filename witness in
        match effect with
        | Some ((Stdout _ | File_access _ | Error _) as effect) ->
          Logs.app (fun m -> m "     status : true %a" pp_effect effect);
          Some (witness, effect)
        | Some (File file as effect) ->
          ignore @@ OS.Path.delete (Fpath.v file);
          Logs.app (fun m -> m "     status : true %a" pp_effect effect);
          Some (witness, effect)
        | None ->
          Logs.app (fun m -> m "     status : false (no side effect)");
          None )
      witnesses
  in
  write_report ~workspace filename effectful_payloads

let main { filename; workspace } () =
  match replay filename workspace with
  | Error (`Msg msg) ->
    Logs.err (fun m -> m "%s" msg);
    1
  | Ok () -> 0
