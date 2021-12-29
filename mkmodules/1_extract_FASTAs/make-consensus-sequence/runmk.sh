#!/usr/bin/env bash

#Find all *out files
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.vcf.gz" \
| sed "s#.vcf.gz#.fa.consensus#" \
| xargs mk
