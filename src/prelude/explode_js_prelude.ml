include Prelude

module Option = struct
  include Option

  let[@inline] ( let* ) v f = Option.bind v f

  let[@inline] ( let+ ) v f = Option.map f v
end

module Result = struct
  include Result

  let[@inline] ( let* ) v f = Result.bind v f

  let[@inline] ( let+ ) v f = Result.map f v

  let list_map f vs =
    let rec loop acc = function
      | [] -> Ok (List.rev acc)
      | hd :: tl ->
        let* v = f hd in
        loop (v :: acc) tl
    in
    loop [] vs

  let list_iter f vs =
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

  let[@inline] ( let* ) v f = List.concat_map f v

  let[@inline] ( let+ ) v f = List.map f v
end
