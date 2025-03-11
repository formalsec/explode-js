# Explode-js

Automatic exploit generation for Node.js applications. See [examples]

### Build from source

- Install the library dependencies:

```sh
git clone https://github.com/formalsec/explode-js.git
cd explode-js
opam install . --deps-only
```

- Build and test:

```sh
dune build
dune runtest
```

- Install `explode-js` on your path by running:

```sh
dune install
```

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
