# Explode-js

Automatic exploit generation for Node.js applications.

## Build

### Build from source

when building **explode-js** from source, it is recommended that you first ensure the following:

- Install [opam](https://opam.ocaml.org/doc/Install.html) and bootstrap the OCaml compiler:

<!-- $MDX skip -->
```sh
$ opam init
$ opam switch create 5.3.0 5.3.0
```

- Install [direnv](https://direnv.net/). And, do:

```sh
$ cp example.envrc .envrc
$ direnv allow
```

- Install [neo4j](https://neo4j.com/docs/operations-manual/current/installation/). In ubuntu do:

```sh
# Download Neo4j GPG key and add it to apt
$ wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add -

# Add Neo4j APT repository
$ echo 'deb https://debian.neo4j.com stable 5' | tee -a /etc/apt/sources.list.d/neo4j.list

# Update package list and install neo4j 5.26.4
$ apt-get update && apt-get install -y neo4j=1:5.26.4 && \
```

Then, you can proceed with the installation of Explode-js:

- Clone the repository and its dependencies, then run the `setup.ml` script:

<!-- $MDX skip -->
```sh
$ git clone https://github.com/formalsec/explode-js.git
# Use the latest stable release
$ cd explode-js
$ git submodule update --init
$ ./scripts/setup.ml
```

- To run tests:

<!-- $MDX skip -->
```sh
$ dune build @test-unit
```

### Build using docker

Building **explode-js** using Docker is only recommended for internal use, as it requires checking out the vendored development version of ECMA-SL.

To install **explode-js**, run the following command:

<!-- $MDX skip -->
```sh
# Checkout submodules
$ git submodule update --init
# Build the image
$ docker build . -t explode-js:latest
# Run the image
$ docker run --rm -it explode-js
```

## Examples

For examples on how to run explode-js in different settings, see [examples].

## Evaluation

For benchmarking and evaluation see [bench]

[bench]: ./bench
[examples]: ./example

## Publications

- [Explode.js]: Filipe Marques, Mafalda Ferreira, André Nascimento, Miguel Coimbra, Nuno Santos, Limin Jia, and José Fragoso Santos.
_"Automated Exploit Generation for Node.js Packages"_, in
Proceedings of the 46th ACM SIGPLAN Conference on Programming Language Design and Implementation (PLDI'25), 2025.

[Explode.js]: https://www.filipeom.dev/assets/pdf/marques_pldi25.pdf

## License

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
