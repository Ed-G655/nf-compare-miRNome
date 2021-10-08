#!/usr/bin/env bash

#Find all *out files
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.mirmapout" \
| sed "s#out#id#" \
| xargs mk
