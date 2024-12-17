include Stdlib

module Result = struct
  include Result

  let ( let* ) v f = Result.bind v f

  let ( let+ ) v f = Result.map f v

  let list_map ~f vs =
    let rec loop acc = function
      | [] -> Ok (List.rev acc)
      | hd :: tl ->
        let* v = f hd in
        loop (v :: acc) tl
    in
    loop [] vs

  let list_iter ~f vs =
    let rec loop = function
      | [] -> Ok ()
      | hd :: tl ->
        let* () = f hd in
        loop tl
    in
    loop vs
end

module List = struct
  include List

  let ( let* ) v f = List.concat_map f v

  let ( let+ ) v f = List.map f v
end
