#!/bin/bash -e

log()
{
	printf "$(basename $0): $1\n" >&2
}

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
		printf("%s RPATH ... NOK:\n", elf) > "/dev/stderr";
		for (p in path)
			printf("\t%s\n", path[p]) > "/dev/stderr";
		stat=1;
	}
	else if (verbose)
		printf("%s RPATH ... OK\n", elf) > "/dev/stderr";
}

END {
	exit stat
}'

validate_rpath()
{
	local path="$1"
	local match="$2"

	${READELF:-readelf} -d $path | awk -F'[][]' \
	                       -v elf="$path" \
	                       -v regex="$match" \
	                       -v verbose="$verbose" \
	                       "$awk_script"
}

validate_subtree_rpath()
{
	local dir="$1"
	local match="$2"
	local stat=0
	local f

	find "$dir" -type f | while read f; do
		case "$(file --brief --mime "$f")" in
		"application/x-executable; charset=binary" | \
		"application/x-pie-executable; charset=binary" | \
		"application/x-sharedlib; charset=binary")
			if ! validate_rpath "$f" "$match"; then
				stat=1
			fi;;
		esac
	done

	return $stat
}

# Show help
usage() {
	local ret=$1

	cat >&2 <<_EOF
Usage: $(basename $0) [OPTIONS] <DIR> <MATCH>

Validate RPATH/RUNPATH of all binaries, shared libraries and objects found under
<DIR> directory.

With OPTIONS:
  -v|--verbose -- be verbose
  -h|--help    -- this help message

Where:
  DIR       -- pathname to directory hierarchy
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
            --options hv \
            --longoptions help,verbose \
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
	-v|--verbose) verbose=1;;
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

validate_subtree_rpath "$dir" "$match"
