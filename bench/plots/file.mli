(** [find p] returns first file path for the pattern [p] if it exists.
    Otherwise, returns and error *)
val find : Fpath.t -> (Fpath.t, [> `Msg of string ]) result

val find_all : Fpath.t -> (Fpath.t list, [> `Msg of string ]) result
