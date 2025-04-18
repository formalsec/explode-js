#!/bin/bash

pgrep -f "neo4j" > /dev/null || neo4j start

pushd datasets

runner run \
  --run-mode full-zeroday \
  --timeout 300 \
  --output zeroday-output \
  ./index-zeroday.json

popd

python3 table_explode-js_zeroday.py
