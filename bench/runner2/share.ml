let search_file (location : string list) (file : string) : string option =
  List.find_map
    (fun dir ->
      let filename = Filename.concat dir file in
      if Sys.file_exists filename then Some filename else None )
    location

module Templates = struct
  let root = Site.Sites.templates

  let index = search_file root "index.html" |> Option.get

  let results = search_file root "results.html" |> Option.get

  let output = search_file root "output.html" |> Option.get

  let not_found = search_file root "404.html" |> Option.get
end

module Static = struct
  let root = Site.Sites.static
end
