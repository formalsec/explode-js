#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-22 \
  --output CWE-22 \
  ./index.json

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-78 \
  --output CWE-78 \
  ./index.json

runner run \
  --run-mode full \
  --timeout 300 \
  --filter CWE-94 \
  --output CWE-94 \
  ./index.json

runner run \
  --run-mode full \
  --proto-pollution \
  --timeout 300 \
  --filter CWE-1321 \
  --output CWE-1321 \
  ./index.json

popd

python3 table_explode-js.py
