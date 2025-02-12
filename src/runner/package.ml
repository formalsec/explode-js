open Syntax
module Util = Yojson.Basic.Util

type t =
  { package : string
  ; version : string
  ; vulns : Vulnerability.t list
  }

let from_json json =
  let package = Util.member "package" json |> Util.to_string in
  let version = Util.member "version" json |> Util.to_string in
  let* vulns =
    Util.member "vulns" json |> Util.to_list
    |> list_bind_map Vulnerability.from_json
  in
  Ok { package; version; vulns }
