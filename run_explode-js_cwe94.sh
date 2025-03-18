#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-94 \
  --output CWE-94 \
  ./index.json

popd

python table_explode-js.py
