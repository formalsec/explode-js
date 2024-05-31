(lang dune 3.15)

(name explode_js)

(generate_opam_files true)

(source
 (github explode-js/explode-js))

(authors "Filipe Marques")

(maintainers "Filipe Marques")

(license "GPL-3.0-or-later")

(documentation https://url/to/documentation)

(package
 (name explode_js)
 (synopsis "Automatic exploit generation for Node.js")
 (description "Explode.js: Automatic exploit generation engine for Node.js applications")
 (depends
  ocaml
  dune
  cmdliner
  (ecma-sl (= "0.0.3")))
 (tags
  ("symbolic execution" javascript exploit)))
