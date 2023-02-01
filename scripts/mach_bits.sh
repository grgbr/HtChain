#!/bin/sh -e

if [ $# -eq 0 ]; then
	CC=cc
else
	CC="$*"
fi

if ! query=$($CC -Q --help=target); then
	exit 1
fi

if echo "$query" | grep --quiet -- '-m64[[:blank:]]\+\[enabled\]'; then
	echo 64
elif echo "$query" | grep --quiet -- '-m32[[:blank:]]\+\[enabled\]'; then
	echo 32
elif echo "$query" | grep --quiet -- '-m16[[:blank:]]\+\[enabled\]'; then
	echo 16
else
	echo "Unknown machine word size !" >&2
	exit 1
fi
