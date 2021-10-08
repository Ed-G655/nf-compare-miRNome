#!/usr/bin/env bash

#Find all *.ts_id files
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.mirna.txt" \
| sed "s#.mirna.txt#.tsout#" \
| xargs mk 
