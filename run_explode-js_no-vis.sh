#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode run-no-vis \
  --timeout 100 \
  --output no-vis \
  ./index.json

popd
