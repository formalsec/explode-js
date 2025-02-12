module Share = struct
  let nodejs : string list = Site.Sites.nodejs

  let search_file (location : string list) (file : string) : string option =
    List.find_map
      (fun dir ->
        let filename = Filename.concat dir file in
        if Sys.file_exists filename then Some filename else None )
      location

  let esl_symbolic_config () = search_file nodejs "esl_symbolic.js"
end
