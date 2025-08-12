#!/usr/bin/env ocaml

let skip_python = ref false

let () =
  let usage = Format.sprintf "%s [--skip-graphjs]" Sys.argv.(0) in
  let spec_list =
    [ ( "--skip-graphjs"
      , Arg.Set skip_python
      , "Skip graphjs's python configuration" )
    ]
  in
  Arg.parse spec_list ignore usage

let with_dir fpath f =
  let cwd = Sys.getcwd () in
  Sys.chdir fpath;
  Fun.protect ~finally:(fun () -> Sys.chdir cwd) f

let on_fail res msg = if res <> 0 then Format.ksprintf failwith "Error: %s" msg

let opam_install pkg =
  Format.ksprintf Sys.command "opam install %s -y --confirm-level=unsafe-yes"
    pkg

let opam_exec rest = Format.ksprintf Sys.command "opam exec -- %s" rest

let setup_graphjs () =
  Format.printf "Installing graphjs ...@.";
  with_dir "vendor/graphjs" @@ fun () ->
  on_fail
    (Sys.command "pip install -r ./requirements.txt")
    "Could not install graphjs's python requirements";
  with_dir "parser" @@ fun () ->
  on_fail
    (Sys.command "npm install")
    "Could not install graphjs's normalizer dependencies";
  on_fail (Sys.command "npm exec tsc") "Could not compile graphjs's normalizer"

let setup_z3 () =
  Format.printf "Installing Z3 ...@.";
  on_fail (opam_install "z3") "Could not install z3 through opam!"

let setup_explodejs () =
  Format.printf "Installing Explode-js ...@.";
  on_fail
    (opam_install ". --deps-only --with-test --with-doc")
    "Could not install Explode-js's dependencies";
  on_fail
    (opam_exec "dune build @install --profile release")
    "Could not build Explode-js!";
  on_fail (opam_exec "dune install") "Could not install Explode-js!"

let () =
  if !skip_python then () else setup_graphjs ();
  setup_z3 ();
  setup_explodejs ()
