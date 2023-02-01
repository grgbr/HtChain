#!/bin/sh -ex

if [ $# -eq 0 ]; then
	CC=cc
else
	CC="$*"
fi

if ! mach_bits=$($CC -print-search-dirs | \
	             sed --silent '/^libraries:[[:blank:]]\+=/p'); then
	exit 1
fi

if echo "$mach_bits" | grep --quiet lib64; then
	echo 64
elif echo "$mach_bits" | grep --quiet lib32; then
	echo 32
fi
