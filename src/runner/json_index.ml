open Syntax

type t = Package.t list

module Parse = struct
  let from_file path =
    let path = Fpath.to_string path in
    Yojson.Basic.from_file ~fname:path path
    |> Yojson.Basic.Util.to_list
    |> list_bind_map Package.from_json
end
