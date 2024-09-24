(lang dune 3.15)

(using mdx 0.4)

(using dune_site 0.1)

(name explode_js)

(generate_opam_files true)

(source
 (github explode-js/explode-js))

(authors "Filipe Marques")

(maintainers "Filipe Marques")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name explode_js)
 (synopsis "Automatic exploit generation for Node.js")
 (description "Explode.js: Automatic exploit generation engine for Node.js applications")
 (depends
  bos
  cmdliner
  dune
  dune-site
  ecma-sl
  explode_js-instrumentation
  extunix
  fpath
  mdx
  ocaml
  yojson)
 (tags
  ("symbolic execution" javascript exploit))
 (sites
  (share nodejs)))

(package
 (name explode_js-instrumentation)
 (synopsis "Instrumentation2")
 (description "Instrumentation2")
 (depends
  (bisect_ppx (and :with-test (>= 2.5.0)))
  (bos (>= 0.2.1))
  (cmdliner (>= 1.2.0))
  dune
  ocaml
  (yojson (>= 2.1.2)))
 (tags
  (javascript nodejs exploit vulnerability)))
