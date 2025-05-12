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

### Publications

- [Explode.js]: Filipe Marques, Mafalda Ferreira, André Nascimento, Miguel Coimbra, Nuno Santos, Limin Jia, and José Fragoso Santos.
_"Automated Exploit Generation for Node.js Packages"_, in
Proceedings of the 46th ACM SIGPLAN Conference on Programming Language Design and Implementation (PLDI'25), 2025.

[Explode.js]: https://syssec.dpss.inesc-id.pt/papers/marques_pldi25.pdf

### License

See [LICENSE].

    MIT License

    Copyright (c) 2024 Explode-js

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

[LICENSE]: ./LICENSE
