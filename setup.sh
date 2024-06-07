#!/usr/bin/env bash

# Configure new switch and install ecma-sl
opam init --disable-sandboxing --shell-setup -y \
&& opam switch create -y ecma-sl 4.14.1 \
&& eval $(opam env --switch=ecma-sl) \
&& echo "eval \$(opam env --switch=ecma-sl)" >> ~/.bash_profile \
&& opam install -y vendor/ECMA-SL \
&& opam install -y .
