module Result = struct
  let ( let* ) = Result.bind

  let list_bind_map f l =
    let rec list_bind_map_cps f l k =
      match l with
      | [] -> k (Ok [])
      | hd :: tl ->
        list_bind_map_cps f tl @@ fun rest ->
        let* rest in
        let* hd = f hd in
        k (Ok (hd :: rest))
    in
    list_bind_map_cps f l Fun.id
end
