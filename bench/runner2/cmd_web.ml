open Jingoo
module S = Tiny_httpd

let outputs db timestamp vuln_id file _req =
  let results = Run_result.select_db ~timestamp db in
  let v = List.find (fun (v : Run_result.t) -> v.vuln.id = vuln_id) results in
  let contents =
    match file with
    | "stdout" -> v.raw.stdout
    | "stderr" -> v.raw.stderr
    | _ -> Jg_template.from_file Templates.not_found
  in
  S.Response.make_string (Ok contents)

let results db timestamp _req =
  let open Jg_types in
  let results =
    Run_result.select_db ~timestamp db
    |> List.sort (fun (r1 : Run_result.t) r2 -> compare r1.vuln.id r2.vuln.id)
    |> List.map Run_result.to_jg
  in
  let models = [ ("timestamp", Tint timestamp); ("results", Tlist results) ] in
  let page = Jg_template.from_file ~models Templates.results in
  S.Response.make_string (Ok page)

let root db _req =
  let open Jg_types in
  let runs = Run_metadata.select_db db |> List.map Run_metadata.to_jg in
  let models = [ ("title", Tstr "Explode-js"); ("runs", Tlist runs) ] in
  let page = Jg_template.from_file ~models Templates.index in
  S.Response.make_string (Ok page)

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

  Fmt.epr "listening on http://%s:%d@." (S.addr server) (S.port server);
  match S.run server with Ok () -> Ok () | Error e -> Error (`Exn e)
