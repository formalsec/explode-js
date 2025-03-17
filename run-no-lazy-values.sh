#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full \
  --lazy-values false \
  --timeout 300 \
  --output no-lazy-values \
  ./index.json

# Generate some tables?
popd
