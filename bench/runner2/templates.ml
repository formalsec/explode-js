let templates = Site.Sites.templates

let search_file (location : string list) (file : string) : string option =
  List.find_map
    (fun dir ->
      let filename = Filename.concat dir file in
      if Sys.file_exists filename then Some filename else None )
    location

let index = search_file templates "index.html" |> Option.get

let results = search_file templates "results.html" |> Option.get
