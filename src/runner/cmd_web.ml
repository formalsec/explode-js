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

let export_csv db timestamp _req =
  let results =
    Run_result.select_db ~timestamp db
    |> List.sort (fun (r1 : Run_result.t) r2 -> compare r1.vuln.id r2.vuln.id)
  in
  S.Response.make_string (Ok (Run_result.to_csv_string_short results))

module Sset = Set.Make (String)

let export_outcomes db timestamp _req =
  (* FIXME: This is pretty hackish thing I made while trying not to fall asleep.
     Review it with fresh eyes *)
  let module Json = Yojson.Basic in
  let module Util = Json.Util in
  let results = Run_result.select_db ~timestamp db in
  let results =
    List.map
      (fun result ->
        let Run_result.{ pkg; vuln; report; control_path; exploit; _ } =
          result
        in
        match report with
        | "" ->
          [ Fmt.str "%s|%s|%a|%B|%B|--|--|--|--" pkg.package pkg.version
              Vulnerability.pp_csv vuln control_path exploit
          ]
        | _ -> begin
          let prefix =
            Fmt.str "%s|%s|%a|%B|%B" pkg.package pkg.version
              Vulnerability.pp_csv vuln control_path exploit
          in
          let reports = Json.from_string report |> Util.to_list in
          let res =
            List.concat_map
              (fun json ->
                let filename = Util.member "filename" json |> Util.to_string in
                let failures = Util.member "failures" json |> Util.to_list in
                List.map
                  (fun failure ->
                    let type_ = Util.member "type" failure |> Util.to_string in
                    let sink =
                      String.escaped
                        (Util.member "sink" failure |> Util.to_string)
                    in
                    Fmt.str "%s|%s|%s|%s" prefix filename type_ sink )
                  failures )
              reports
          in
          res
        end )
      results
  in
  let header =
    "package|version|id|cwe|filename|control-path|exploit|symbolic-test|outcome|sink"
  in
  let results = header :: List.flatten results in
  S.Response.make_string (Ok (String.concat "\n" results))

let main ~address ~port ~db_path =
  Db.with_db ~mode:`READONLY (Fpath.to_string db_path) @@ fun db ->
  let server = S.create ~addr:address ~port () in

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
    (export_csv db);
  S.add_route_handler server
    S.Route.(exact "results" @/ int @/ exact "outcomes" @/ return)
    (export_outcomes db);

  (* Dirs *)
  let config = S.Dir.default_config () in
  let dir = List.hd Share.Static.root in
  S.Dir.add_dir_path ~config ~dir ~prefix:"static" server;

  Fmt.epr "listening on http://%s:%d@." (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> Ok ()
  | Error e -> Error (`Exn e)
