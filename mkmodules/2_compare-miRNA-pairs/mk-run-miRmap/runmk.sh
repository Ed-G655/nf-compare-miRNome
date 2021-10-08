#!/usr/bin/env bash

#Find all *.mp_id files
find -L . \
  -type f \
  -name "*.mirna.fa" \
| sed "s#.mirna.fa#.mirmapout#" \
| xargs mk
