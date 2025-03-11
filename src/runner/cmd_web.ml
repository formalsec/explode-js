open Jingoo
module S = Tiny_httpd

let ( let* ) = Result.bind

let root db _req =
  let open Jg_types in
  let runs = Run_metadata.select_db db |> List.map Run_metadata.to_jg in
  let models = [ ("title", Tstr "Explode-js"); ("runs", Tlist runs) ] in
  let page = Jg_template.from_file ~models Share.Templates.index in
  S.Response.make_string (Ok page)

let results db timestamp _req =
  let open Jg_types in
  let results =
    Run_result.select_db ~timestamp db
    |> List.sort (fun (r1 : Run_result.t) r2 -> compare r1.vuln.id r2.vuln.id)
    |> List.map Run_result.to_jg
  in
  let models = [ ("timestamp", Tint timestamp); ("results", Tlist results) ] in
  let page = Jg_template.from_file ~models Share.Templates.results in
  S.Response.make_string (Ok page)

let outputs db timestamp vuln_id file _req =
  let results = Run_result.select_db ~timestamp db in
  let v = List.find (fun (v : Run_result.t) -> v.vuln.id = vuln_id) results in
  let contents =
    match file with
    | "stdout" -> Ok v.raw.stdout
    | "stderr" -> Ok v.raw.stderr
    | "report" -> Ok v.report
    | _ ->
      Error
        ( S.Response_code.not_found
        , Jg_template.from_file Share.Templates.not_found )
  in
  S.Response.make_string
  @@
  let* contents in
  let models =
    Jg_types.
      [ ("title", Tstr file)
      ; ("timestamp", Tint timestamp)
      ; ("output", Tstr contents)
      ]
  in
  Ok (Jg_template.from_file ~models Share.Templates.output)

let to_csv db timestamp _req =
  let results =
    Run_result.select_db ~timestamp db
    |> List.sort (fun (r1 : Run_result.t) r2 -> compare r1.vuln.id r2.vuln.id)
  in
  S.Response.make_string (Ok (Run_result.to_csv_string_short results))

let main addr port db_path =
  Db.with_db ~mode:`READONLY (Fpath.to_string db_path) @@ fun db ->
  let server = S.create ~addr ~port () in

  (* Routes and handlers *)
  S.add_route_handler server S.Route.return (root db);
  S.add_route_handler server
    S.Route.(exact "results" @/ int @/ return)
    (results db);
  S.add_route_handler server
    S.Route.(exact "results" @/ int @/ int @/ string @/ return)
    (outputs db);
  S.add_route_handler server
    S.Route.(exact "results" @/ int @/ exact "csv" @/ return)
    (to_csv db);
  (* Dirs *)
  let config = S.Dir.default_config () in
  let dir = List.hd Share.Static.root in
  S.Dir.add_dir_path ~config ~dir ~prefix:"static" server;

  Fmt.epr "listening on http://%s:%d@." (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> Ok ()
  | Error e -> Error (`Exn e)
