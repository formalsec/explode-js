#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd datasets

runner run \
  --run-mode run-no-vis \
  --timeout 100 \
  --output no-vis \
  ./index.json

popd

python3 table_explode-js2.py datasets/no-vis/results.csv
