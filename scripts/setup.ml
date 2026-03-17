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

let in_dir fpath f =
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
  in_dir "vendor/graphjs" @@ fun () ->
  execute "pip install -r ./requirements.txt"
    "Could not install graphjs's python requirements";
  in_dir "parser" @@ fun () ->
  execute "npm install" "Could not install graphjs's normalizer dependencies";
  execute "npm exec tsc" "Could not compile graphjs's normalizer"

let setup_cvc5 () =
  let execute = execute "setup_cvc5" in
  execute (opam_install "cvc5")
    "Could not checkout cvc5's vendored dependencies"

let _ = setup_cvc5

let setup_z3 () =
  let execute = execute "setup_z3" in
  execute (opam_install "z3") "Could not checkout z3's vendored dependencies"

let setup_explodejs () =
  let execute = execute "setup_explodejs" in
  Format.printf "Installing Explode-js ...@.";
  execute
    (opam_install ". --deps-only --with-test --with-doc")
    "Could not install Explode-js's dependencies";
  setup_z3 ();
  execute (opam_exec "dune build @install") "Could not build Explode-js!";
  execute (opam_exec "dune install") "Could not install Explode-js!"

let () =
  if !skip_python then () else setup_graphjs ();
  setup_explodejs ()
