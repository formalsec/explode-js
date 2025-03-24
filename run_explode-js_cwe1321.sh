#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd bench/datasets

runner run \
  --run-mode full \
  --proto-pollution \
  --timeout 300 \
  --filter CWE-1321 \
  --output CWE-1321 \
  ./index.json

popd

python3 table_explode-js.py
