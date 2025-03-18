#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-78 \
  --output CWE-78 \
  ./index.json

# Generate some tables?
popd
