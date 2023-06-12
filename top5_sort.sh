#! /bin/bash/

# tab delim .txt, sort by column 7 value, find top5
for f in *.txt; do echo $f; tail -n +2 $f | sort -t$'\t' -k 7nr | head -5 ; echo '\n';  done > top5.log
