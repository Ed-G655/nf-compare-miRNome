#!/usr/bin/env bash


#Find all *.txt files
find -L . \
  -type f \
  -name "*.mirna.fa" \
| sed 's#.mirna.fa#.mirna.txt#' \
| xargs mk
