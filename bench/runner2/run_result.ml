type t =
  { pkg : Package.t
  ; vuln : Vulnerability.t
  ; raw : Run_proc_result.t
  ; timestamp : int
  }

let pp fmt { pkg; vuln; raw; _ } =
  Fmt.pf fmt "@[<v 2>Run %d: %s@%s@;File %a@;%a@]" vuln.id pkg.package
    pkg.version Fpath.pp vuln.filename Run_proc_result.pp raw

let pp_csv fmt { pkg; vuln; raw; timestamp } =
  Fmt.pf fmt "%s,%s,%a,%a,%a" pkg.package pkg.version Vulnerability.pp_csv vuln
    Run_proc_result.pp_csv raw Fmt.int timestamp

let to_jg { pkg; vuln; raw; timestamp } =
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
      ; ("timestamp", Tint timestamp)
      ] )

let to_csv results out_file =
  let csv_string =
    Fmt.str
      "package,version,id,cwe,filename,returncode,stdout,stderr,rtime,utime,stime,timestamp@\n\
       %a"
      (Fmt.list ~sep:(fun fmt () -> Fmt.pf fmt "@\n") pp_csv)
      results
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
        timestamp INTEGER
      );
    |}
  |> Db.to_result

let to_db db { pkg; vuln; raw; timestamp } =
  Db.exec_no_cursor db
    "INSERT INTO run_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    ~ty:
      Db.Ty.[ text; text; int; text; int; blob; blob; float; float; float; int ]
    pkg.package pkg.version vuln.id
    (Fpath.to_string vuln.filename)
    raw.returncode raw.stdout raw.stderr raw.rtime raw.utime raw.stime timestamp
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
        ( [ text; text; int; text; int; blob; blob; float; float; float; int ]
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
            timestamp
          ->
            let pkg = { Package.package; version; vulns = [] } in
            let cwe = Cwe.CWE_22 in
            let filename = Fpath.v filename in
            let lineno = "?" in
            let vuln = { Vulnerability.cwe; filename; lineno; id } in
            let raw =
              { Run_proc_result.returncode
              ; stdout
              ; stderr
              ; rtime
              ; utime
              ; stime
              }
            in
            { pkg; vuln; raw; timestamp } )
    ~f:Db.Cursor.to_list_rev
  |> Db.unwrap_db
