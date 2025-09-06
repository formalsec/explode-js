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

let execute f_name cmd err_msg =
  let res = Sys.command cmd in
  if res <> 0 then Format.ksprintf failwith "%s: %s" f_name err_msg

let opam_install pkg =
  Format.sprintf "opam install %s -y --confirm-level=unsafe-yes" pkg

let opam_exec rest = Format.sprintf "opam exec -- %s" rest

let setup_graphjs () =
  let execute = execute "setup_graphjs" in
  Format.printf "Installing graphjs ...@.";
  with_dir "vendor/graphjs" @@ fun () ->
  execute "pip install -r ./requirements.txt"
    "Could not install graphjs's python requirements";
  with_dir "parser" @@ fun () ->
  execute "npm install" "Could not install graphjs's normalizer dependencies";
  execute "npm exec tsc" "Could not compile graphjs's normalizer"

let setup_z3 () =
  let execute = execute "setup_z3" in
  Format.printf "Installing Z3 ...@.";
  execute (opam_install "z3") "Could not install z3 through opam!"

let setup_explodejs () =
  setup_z3 ();
  let execute = execute "setup_explodejs" in
  Format.printf "Installing Explode-js ...@.";
  execute
    (opam_install ". --deps-only --with-test --with-doc")
    "Could not install Explode-js's dependencies";
  execute
    (opam_exec "dune build @install --profile release")
    "Could not build Explode-js!";
  execute (opam_exec "dune install") "Could not install Explode-js!"

let () =
  if !skip_python then () else setup_graphjs ();
  setup_explodejs ()
