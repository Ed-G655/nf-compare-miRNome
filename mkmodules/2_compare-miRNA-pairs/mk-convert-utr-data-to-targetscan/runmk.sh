#!/usr/bin/env bash

# Find all *txt files

find -L . \
  -type f \
  -name "*.utr.fa" \
| sed "s#.utr.fa#.utr.txt#" \
| xargs mk
