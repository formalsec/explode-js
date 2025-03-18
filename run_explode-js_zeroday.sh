#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode full \
  --timeout 300 \
  --output zeroday-output \
  ./index-zeroday.json

popd
