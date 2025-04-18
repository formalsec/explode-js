#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-94 \
  --output CWE-94 \
  ./index.json

popd

python3 table_explode-js.py
