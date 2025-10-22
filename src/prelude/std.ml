module Option = struct
  include Option

  module Syntax = struct
    let[@inline] ( let* ) v f = Option.bind v f

    let[@inline] ( let+ ) v f = Option.map f v
  end
end

module Result = struct
  include Result

  module Syntax = struct
    let[@inline] ( let* ) v f = Result.bind v f

    let[@inline] ( let+ ) v f = Result.map f v
  end

  let list_map f vs =
    let open Syntax in
    let rec loop acc = function
      | [] -> Ok (List.rev acc)
      | hd :: tl ->
        let* v = f hd in
        loop (v :: acc) tl
    in
    loop [] vs

  let list_iter f vs =
    let open Syntax in
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

  module Syntax = struct
    let[@inline] ( let* ) v f = List.concat_map f v

    let[@inline] ( let+ ) v f = List.map f v
  end
end

module Path = struct
  include Fpath

  let to_yojson fpath = `String (to_string fpath)

  let of_yojson json =
    match json with
    | `String s -> Ok (v s)
    | _ -> Error "invalid_arg: expecting a string"
end
