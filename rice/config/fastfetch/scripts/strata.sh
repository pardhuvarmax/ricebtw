#!/bin/sh
out=""
for i in /bedrock/strata/*; do
    b=$(basename "$i")
    case "$b" in
        bedrock|init|hijacked) continue;;
    esac
    out="$out$b, "
done
echo "${out%, }"
