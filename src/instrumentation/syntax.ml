module Result = struct
  let ( let* ) v f = Result.bind v f

  let ( let+ ) v f = Result.map f v

  let list_map f vs =
    let rec aux acc = function
      | [] -> Ok (List.rev acc)
      | v :: vs -> (
        match f v with Ok v -> aux (v :: acc) vs | Error _ as e -> e )
    in
    aux [] vs
end

module List = struct
  let ( let* ) v f = List.concat_map f v

  let ( let+ ) v f = List.map f v
end
