#!/bin/sh

# get path of sh actually used
p=$(command -v sh)

# resolve symlink fully
p=$(readlink -f "$p")

# extract stratum if present
case "$p" in
    /bedrock/strata/*)
        echo "$p" | cut -d/ -f4
        ;;
    *)
        echo "arch"
        ;;
esac
