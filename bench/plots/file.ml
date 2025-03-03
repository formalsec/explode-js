let ( let* ) = Result.bind

let has_star str = String.exists (function '*' -> true | _ -> false) str

let rec find_glob_parent p =
  let parent = Fpath.parent p in
  let parent_base = Fpath.basename parent in
  if has_star parent_base then find_glob_parent parent else parent

let glob ?(recursive = false) pattern =
  let matcher =
    Dune_re.compile
    @@ Dune_re.Glob.glob ~anchored:true ~double_asterisk:recursive
    @@ Fpath.to_string pattern
  in
  let traverse = if recursive then `Any else `None in
  (* FIXME: this is probably very inefficient *)
  Bos.OS.Dir.fold_contents ~elements:`Any ~traverse
    (fun p acc ->
      let path = Fpath.to_string p in
      if Dune_re.execp matcher path then p :: acc else acc )
    [] (find_glob_parent pattern)

let find pattern =
  let* files = glob ~recursive:true pattern in
  match files with
  | [] ->
    Error
      (`Msg (Format.asprintf "Could not find files with: %a" Fpath.pp pattern))
  | x :: _ -> Ok x

let find_all pattern = glob ~recursive:true pattern
