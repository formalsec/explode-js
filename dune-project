(lang dune 3.20)

(using mdx 0.4)

(using dune_site 0.1)

(name explode_js)

(generate_opam_files true)

(source
 (github explode-js/explode-js))

(authors "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(maintainers "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name explode_js)
 (synopsis "Automatic Exploit Generation for Node.js Packages")
 (description
  "Explode.js is an exploit generation tool for Node.js packages \
  that can automatically synthesize functional exploits for \
  multi-interaction vulnerablitilties. That is, vulnerabilities \
  that require a series of interactions with the vulnerable package \
  to be exploited. Given a vulnerable package, explode-js can \
  identify code injection, command injection, prototype pollution, \
  and path traversal vulnerabilities, and build a JS program that is \
  guaranteed to produce observable side effects, thereby confirming \
  the existence of the vulnerability and eliminating false positives.")
 (depopts
  z3
  cvc5)
 (depends
  bos
  (bisect_ppx (and :with-test (>= 2.5.0)))
  cmdliner
  dune
  dune-site
  dune-glob
  (ecma-sl
   (= "pin"))
  (extunix
   (= "0.4.3"))
  (ppxlib
   (= "0.35.0"))
  ppx_deriving
  fpath
  (mdx :with-test)
  ocaml
  (smtml
   (>= 0.13.0))
  prelude
  yojson
  (ocamlformat
    :with-dev-setup))
 (tags
  ("symbolic execution" javascript exploit))
 (sites
  (share nodejs)))
