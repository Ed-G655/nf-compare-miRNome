#!/usr/bin/env bash

#Find all *.mirmap.id files
find -L . \
  -type f \
  -name "*.mirmapid" \
| sed "s#.mirmapid#.ref#" \
| xargs mk
