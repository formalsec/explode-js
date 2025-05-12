# Explode-js

Automatic exploit generation for Node.js applications.

### Build from source

When building **Explode-js** from source, it is recommended that you first
ensure the following:

- Install [opam](https://opam.ocaml.org/doc/Install.html) and bootstrap
the OCaml compiler:

<!-- $MDX skip -->
```sh
$ opam init
$ opam switch create 5.3.0 5.3.0
```

- Setup a managed Python environment using either [direnv](https://direnv.net/) or
[virtualenv](https://docs.python.org/3/library/venv.html).

Then, you can proceed with the installation of Explode-js:

- Clone the repository and its dependencies, then run the `setup.ml` script:

<!-- $MDX skip -->
```sh
$ git clone https://github.com/formalsec/explode-js.git
$ git submodule update --init
# Or, if you only want to run explode-js and not the evaluation, use:
# $ git submodule update --init bench/graphjs bench/ECMA-SL
$ cd explode-js
$ ./setup.ml
```

- To run tests:

<!-- $MDX skip -->
```sh
$ dune runtest
```

### Examples

For examples on how to run explode-js in different settings, see [examples].

### Evaluation

For benchmarking and evaluation see [bench]

[bench]: ./bench
[examples]: ./example

## Coding Practices

In this project I adopted some practices that made some parts of the code more
readable to me. So please use them:

#### File, Dir, and Path  Variable Naming

For **file** paths: `<something>_file`, e.g., `input_file`,
`scheme_file`, `original_file`.

For **dir** paths: `<something>_dir`, e.g., `nas_dir` or `workspace_dir`.

For paths which may represent a **dir** or a **file**: `<something>_path`, e.g., `input_path`, `output_path`.

For the **data** of a file: `<something>_data`, e.g., `module_data`.
