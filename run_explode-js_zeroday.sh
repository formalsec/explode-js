#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full-zeroday \
  --timeout 300 \
  --output zeroday-output \
  ./index-zeroday.json

popd

python3 table_explode-js_zeroday.py
