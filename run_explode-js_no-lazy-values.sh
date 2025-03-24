#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd bench/datasets

runner run \
  --run-mode full \
  --lazy-values false \
  --timeout 300 \
  --output no-lazy-values \
  ./index.json

popd

python3 table_explode-js2.py bench/datasets/no-lazy-values/results.csv
