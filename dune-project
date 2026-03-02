(lang dune 3.20)

(using menhir 2.1)

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
  cmdliner
  dune
  dune-site
  dune-glob
  (ecma-sl
   (= "dev"))
  extunix
  ppxlib
  ppx_deriving
  ppx_deriving_yojson
  fpath
  (mdx :with-test)
  ocaml
  (smtml
   (>= 0.21.0))
  prelude
  yojson
  (menhir
   (and
    :build
    (>= "20220210")))
  (ocamlformat
    :with-dev-setup))
 (tags
  ("symbolic execution" javascript exploit))
 (sites
  (share nodejs)))
