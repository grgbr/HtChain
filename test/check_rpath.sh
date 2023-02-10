#!/bin/bash -e

log()
{
	printf "$(basename $0): $1\n" >&2
}

# Show help
usage() {
	local ret=$1

	cat >&2 <<_EOF
Usage: $(basename $0) [OPTIONS] <DIR> <MATCH>

Validate RPATH/RUNPATH of all binaries, shared libraries and objects found under
<DIR> directory.

With OPTIONS:
  -h|--help -- this help message

Where:
  DIR       -- pathname to directory hierarchy.
  MATCH     -- a regular expression allowing to identify valid RPATH/RUNPATH
_EOF

	exit $ret
}

# Setup shell behavior.
#
# Pipeline return code is the value of the last (rightmost) command to exit with
# a non-zero status.
set -o pipefail
# All sub-shells will inherit the above settings
export SHELLOPTS

# Check and sanitize command line content
if ! opts=$(getopt \
            --name "$(basename $0)" \
            --options h \
            --longoptions help \
            -- "$@"); then
	# Something went wrong, getopt will put out an error message for us
	echo
	usage 1
fi
# Replace command line with getopt parsed output
eval set -- "$opts"
# Process command line option arguments now that it has been sanitized by getopt
while [ $# -gt 0 ]; do
	case $1 in
	-h|--help)    usage 0;;
	--)           shift 1; break;;
	-*)           log "Unrecognized option \'$1\'\n"; usage 1;;
	*)            break;;
	esac

	shift 1
done

if [ $# -ne 2 ]; then
	log "Invalid number of arguments.\n"
	usage 1
fi

dir="$1"
if [ ! -d "$dir" ]; then
	exit 1
fi

match="$2"

awk_script='
BEGIN {
	stat=0
}

/(RUNPATH)|(RPATH)/ {
	split($2, path, ":");
	warn=0;
	for (p in path) {
		if (path[p] !~ regex) {
			warn=1;
			break;
		}
	}
	if (warn) {
		printf("%s:\n", elf) > "/dev/stderr";
		for (p in path)
			printf("\t%s\n", path[p]) > "/dev/stderr";
		stat=1;
	}
}

END {
	exit stat
}'

validate_rpath()
{
	local path="$1"
	local match="$2"

	readelf -d $path | awk -F'[][]' \
	                       -v elf="$path" \
	                       -v regex="$match" \
	                       "$awk_script"
}

stat=0

find "$dir" -type f | while read f; do
	type=$(file --brief --mime "$f")
	case "$type" in
	"application/x-executable; charset=binary")
		validate_rpath "$f" "$match" || stat=1;;
	"application/x-pie-executable; charset=binary")
		validate_rpath "$f" "$match" || stat=1;;
	"application/x-sharedlib; charset=binary")
		validate_rpath "$f" "$match" || stat=1;;
	esac
done

exit $stat
