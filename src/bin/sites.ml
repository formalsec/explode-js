module Share = struct
  let nodejs : Fpath.t list = List.map Fpath.v Site.Sites.nodejs

  let search_file (locs : Fpath.t list) (file : Fpath.t) : Fpath.t option =
    List.find_map
      (fun dir ->
        let filename = Fpath.(dir // file) in
        let file_exists = Bos.OS.File.exists filename in
        match file_exists with
        | Ok file_exists -> if file_exists then Some filename else None
        | Error (`Msg err) -> Fmt.failwith "%s" err )
      locs

  let esl_symbolic_config () = search_file nodejs (Fpath.v "esl_symbolic.js")
end
