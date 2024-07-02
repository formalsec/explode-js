(lang dune 3.15)

(using mdx 0.4)

(using dune_site 0.1)

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
  ecma-sl
  bos
  fpath
  yojson
  dune-site)
 (tags
  ("symbolic execution" javascript exploit))
 (sites
  (share nodejs)))
