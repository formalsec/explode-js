#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-22 \
  --output CWE-22 \
  ./index.json

# Generate some tables?
popd
