#!/bin/bash -e

log()
{
	printf "$(basename $0): $1\n" >&2
}

# Show help
usage()
{
	local ret=$1

	cat >&2 <<_EOF
Usage: $(basename $0) [OPTIONS] [DIR]

Strip all binary files found under [DIR] directory.
Or files from stdin if not DIR or DIR = -

With OPTIONS:
  -h|--help -- this help message

Where:
  DIR       -- pathname to directory hierarchy.
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

if [ $# -eq 0 ]; then
	dir="-"
elif [ $# -eq 1 ]; then
	dir="$1"
else
	log "Invalid number of arguments.\n"
	usage 1
fi

if [ "$dir" != "-" ] -a [ ! -d "$dir" ]; then
	log "$dir: Invalid directory specified.\n"
	exit 1
fi
# file does not recognize guile 2.2+ object files (byte-compiled files) since
# using a regular ELF format. Skip them as they are not strippable anyway.
#
# Also note that some files are installed read only. This is the reason why we
# make them user writeable (chmod) before stripping...
strip_files()
{
	local f
	while read f; do
		type=$(file --brief --mime "$f")
		case "$type" in
		"application/x-executable; charset=binary")
			echo "STRIP $f" >&2
			chmod u+w "$f"
			strip --strip-all "$f";;
		"application/x-pie-executable; charset=binary")
			echo "STRIP $f" >&2
			chmod u+w "$f"
			strip --strip-all "$f";;
		"application/x-sharedlib; charset=binary")
			echo "STRIP $f" >&2
			chmod u+w "$f"
			strip --strip-unneeded "$f" || true;;
		esac
	done
}

if [ "$dir" -eq "-" ]; then
	strip_files
else
	find "$dir" -type f ! -path "*/guile/*.go" | strip_files
fi