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
  dune-glob
  (ecma-sl
   (= "1.4.0"))
  (extunix
   (= "0.4.3"))
  (ppxlib
   (= "0.35.0"))
  fpath
  (mdx :with-test)
  ocaml
  ; (owl (>= 1.1))
  smtml
  prelude
  yojson
  z3)
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
  dune-glob
  (extunix
   (= "0.4.3"))
  (ppxlib
   (= "0.35.0"))
  explode_js
  jingoo
  logs
  sqlite3
  sqlite3_utils
  tiny_httpd)
  (sites
   (share templates)
   (share static)))
