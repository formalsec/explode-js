let p = Fpath.to_string

let run ~file ~output =
  [ "graphjs"; "--silent"; "--with-types"; "-f"; p file; "-o"; p output ]
