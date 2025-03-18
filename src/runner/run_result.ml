type t =
  { pkg : Package.t
  ; vuln : Vulnerability.t
  ; raw : Run_proc_result.t
  ; report : string
  ; control_path : bool
  ; exploit : bool
  ; timestamp : int
  }

let pp fmt ?progress { pkg; vuln; raw; control_path; exploit; _ } =
  let pp_progress fmt v =
    match v with
    | None -> ()
    | Some (curr, total) -> Fmt.pf fmt " (%a/%a)" Fmt.int curr Fmt.int total
  in
  Fmt.pf fmt
    "@[<v 2>Run %d%a: %s@%s@;File %a@;%a@;Control Path: %a@;Exploit: %a@]"
    vuln.id pp_progress progress pkg.package pkg.version Fpath.pp vuln.filename
    Run_proc_result.pp raw Fmt.bool control_path Fmt.bool exploit

let pp_csv fmt { pkg; vuln; raw; report; control_path; exploit; timestamp } =
  let report = String.escaped report in
  Fmt.pf fmt "%s|%s|%a|%a|%a|%a|%a|%a" pkg.package pkg.version
    Vulnerability.pp_csv vuln Run_proc_result.pp_csv raw Fmt.string report
    Fmt.bool control_path Fmt.bool exploit Fmt.int timestamp

let pp_csv_short fmt { pkg; vuln; raw; control_path; exploit; timestamp; _ } =
  Fmt.pf fmt "%s|%s|%a|%a|%a|%a|%a|%a|%a|%a" pkg.package pkg.version
    Vulnerability.pp_csv vuln Fmt.int raw.returncode Fmt.bool control_path
    Fmt.bool exploit Fmt.float raw.rtime Fmt.float raw.utime Fmt.float raw.stime
    Fmt.int timestamp

let to_jg { pkg; vuln; raw; timestamp; report; control_path; exploit } =
  Jingoo.Jg_types.(
    Tobj
      [ ("package", Tstr pkg.package)
      ; ("version", Tstr pkg.version)
      ; ("vuln_id", Tint vuln.id)
      ; ("filename", Tstr (Fpath.to_string vuln.filename))
      ; ("returncode", Tint raw.returncode)
      ; ("stdout", Tstr raw.stdout)
      ; ("stderr", Tstr raw.stderr)
      ; ("rtime", Tfloat raw.rtime)
      ; ("utime", Tfloat raw.utime)
      ; ("stime", Tfloat raw.stime)
      ; ("report", Tstr report)
      ; ("control_path", Tbool control_path)
      ; ("exploit", Tbool exploit)
      ; ("timestamp", Tint timestamp)
      ] )

let to_csv_string results =
  Fmt.str
    "package|version|id|cwe|filename|returncode|stdout|stderr|rtime|utime|stime|report|control_path|exploit|timestamp@\n\
     %a"
    (Fmt.list ~sep:(fun fmt () -> Fmt.pf fmt "@\n") pp_csv)
    results

let to_csv_string_short results =
  Fmt.str
    "package|version|id|cwe|filename|returncode|control_path|exploit|rtime|utime|stime|timestamp@\n\
     %a"
    (Fmt.list ~sep:(fun fmt () -> Fmt.pf fmt "@\n") pp_csv_short)
    results

let to_csv ?(short = false) results out_file =
  let csv_string =
    (if short then to_csv_string_short else to_csv_string) results
  in
  Out_channel.with_open_text (Fpath.to_string out_file) @@ fun oc ->
  Out_channel.output_string oc csv_string

let prepare_db db =
  Db.exec0 db
    {|CREATE TABLE IF NOT EXISTS
      run_results (
        package TEXT,
        version TEXT,
        vuln_id INTEGER,
        filename TEXT,
        returncode INTEGER,
        stdout BLOB,
        stderr BLOB,
        rtime FLOAT,
        utime FLOAT,
        stime FLOAT,
        report BLOB,
        control_path TEXT,
        exploit TEXT,
        timestamp INTEGER
      );
    |}
  |> Db.to_result

let to_db db { pkg; vuln; raw; report; control_path; exploit; timestamp } =
  Db.exec_no_cursor db
    "INSERT INTO run_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    ~ty:
      Db.Ty.
        [ text
        ; text
        ; int
        ; text
        ; int
        ; blob
        ; blob
        ; float
        ; float
        ; float
        ; blob
        ; text
        ; text
        ; int
        ]
    pkg.package pkg.version vuln.id
    (Fpath.to_string vuln.filename)
    raw.returncode raw.stdout raw.stderr raw.rtime raw.utime raw.stime report
    (Bool.to_string control_path)
    (Bool.to_string exploit) timestamp
  |> Db.unwrap_db

let select_db ?timestamp db =
  let query =
    let query0 = "SELECT * FROM run_results" in
    match timestamp with
    | Some timestamp -> Fmt.str "%s WHERE timestamp=%d;" query0 timestamp
    | None -> Fmt.str "%s;" query0
  in
  Db.exec_no_params db query
    ~ty:
      Db.Ty.
        ( [ text
          ; text
          ; int
          ; text
          ; int
          ; blob
          ; blob
          ; float
          ; float
          ; float
          ; blob
          ; text
          ; text
          ; int
          ]
        , fun package
            version
            id
            filename
            returncode
            stdout
            stderr
            rtime
            utime
            stime
            report
            control_path
            exploit
            timestamp
          ->
            let pkg = { Package.package; version; vulns = [] } in
            let cwe = Explode_js.Cwe.CWE_22 in
            let filename = Fpath.v filename in
            let lineno = "?" in
            let vuln =
              { Vulnerability.cwe; filename; package_dir = None; lineno; id }
            in
            let raw =
              { Run_proc_result.returncode
              ; stdout
              ; stderr
              ; rtime
              ; utime
              ; stime
              }
            in
            let control_path = bool_of_string control_path in
            let exploit = bool_of_string exploit in
            { pkg; vuln; raw; timestamp; report; control_path; exploit } )
    ~f:Db.Cursor.to_list_rev
  |> Db.unwrap_db
