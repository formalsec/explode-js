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
  (bisect_ppx (and :with-test (>= 2.5.0)))
  cmdliner
  dune
  dune-site
  explode_js-instrumentation
  extunix
  fpath
  mdx
  ocaml
  (owl (>= 1.1))
  yojson
  glob)
 (tags
  ("symbolic execution" javascript exploit))
 (sites
  (share nodejs)))

(package
 (name explode_js-runner)
 (synopsis "Explode-js runner")
 (description "explode_js-runner")
 (depends
  dune
  dune-site
  explode_js
  jingoo)
  (sites
   (share templates)
   (share static)))
