#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode run-no-vis \
  --timeout 100 \
  --output no-vis \
  ./index.json

popd

python table_explode-js2.py bench/datasets/no-vis/results.csv
