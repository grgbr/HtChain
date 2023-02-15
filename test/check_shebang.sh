#!/bin/bash -e

log()
{
	printf "$(basename $0): $1\n" >&2
}

validate_shebang()
{
	local path="$1"
	local interp="$2"
	local prefix="$3"
	local regex

	if ! head -n 1 $f | grep -q "^#!.*${interp}"; then
		return 0
	fi

	regex="^#\![[:blank:]]*${prefix}/bin/${interp}"
	if ! head -n 1 $f | grep -q "$regex"; then
		echo "Checking ${interp} $f ... NOK" >&2
		return 1
	else
		if [ $verbose -ne 0 ]; then
			echo "Checking ${interp} $f ... OK" >&2
		fi
	fi
}

validate_subtree_shebang()
{
	local dir="$1"
	local prefix="$2"
	local stat=0

	for f in $(find "$dir" -type f); do
		res=""
		case $(file --brief --mime-type "$f") in
		text/x-script.python)
			validate_shebang "$f" "python" "$prefix" || stat=1;;
		text/x-perl)
			validate_shebang "$f" "perl" "$prefix" || stat=1;;
		esac
	done

	return $stat
}

# Show help
usage() {
	local ret=$1

	cat >&2 <<_EOF
Usage: $(basename $0) [OPTIONS] <DIR> <PREFIX>

Strip all binary files found under <DIR> directory.

With OPTIONS:
  -v|--verbose -- be verbose
  -h|--help    -- this help message

Where:
  DIR       -- pathname to directory hierarchy
  PREFIX    -- install hierarchy prefix pathname
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
verbose=0
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

prefix="$2"
if [ -z "$prefix" ]; then
	exit 1
fi

validate_subtree_shebang "$dir" "$prefix"
