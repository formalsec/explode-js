#!/bin/bash

pushd bench/datasets

runner run \
  --run-mode run-no-vis \
  --timeout 300 \
  ./index.json

popd
