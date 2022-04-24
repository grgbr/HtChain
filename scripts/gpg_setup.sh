#!/bin/bash -e

GNU_KEYRING_URL="https://ftp.gnu.org/gnu/gnu-keyring.gpg"

# Default keys.openpgp.org server strip UIDs unless the owner of the
# corresponding email address has allowed them to be published.
# This prevents us from importing multiple public keys used to sign software
# packages.
# Uses MIT key server instead.
GPG_KEY_SERVER="--keyserver hkps://pgp.mit.edu"

log()
{
	printf "$(basename $0): $1\n" >&2
}

# Show help
usage() {
	local ret=$1

	cat >&2 <<_EOF
Usage: $(basename $0) [OPTIONS] <FETCHDIR>

Setup local GPG keyring for verifying downloaded source distributions
authenticity.

With OPTIONS:
  -h|--help -- this help message

Where:
  FETCHDIR  -- pathname to fetch directory.
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

if [ $# -ne 1 ]; then
	log "Invalid number of arguments.\n"
	usage 1
fi

fetchdir="$1"
if [ ! -d "$fetchdir" ]; then
	log "Invalid fetching directory: '$fetchdir': No such directory."
	exit 1
fi

lock="$(realpath --canonicalize-missing $fetchdir/$(basename $0).lock)"
keyring="$(realpath --canonicalize-missing $fetchdir/keyring.gpg)"
gpg_homedir="$(realpath --canonicalize-missing $fetchdir/.gnupg)"
gpg_cmd="gpg --homedir $gpg_homedir --batch $GPG_KEY_SERVER --quiet"

exec 200<>$lock
if ! flock --nonblock --exclusive 200; then
	log "'$lock': Failed to acquire lock: is another instance running ?"
	exit 1
fi

trap "trap '' INT QUIT TERM HUP EXIT; rm -f $keyring $lock" EXIT

log "Downloading GNU public GPG keyring..."
if ! curl --silent --output $keyring "$GNU_KEYRING_URL"; then
	log "Failed to download GNU public GPG keyring."
	exit 1
fi

log "Importing GNU public GPG keyring..."
if ! $gpg_cmd --import $keyring; then
	log "Failed to import GNU public GPG keyring."
	exit 1
fi

log "Refreshing GNU public GPG keyring..."
if ! $gpg_cmd --refresh-keys; then
	log "Failed to refresh GNU public GPG keyring."
	exit 1
fi

log "Marking GNU public GPG keys as ultimately trusted..."
if ! $gpg_cmd --export-ownertrust | \
     awk -F':' '{ print $1 ":6:" }' | \
     $gpg_cmd --import-ownertrust; then
	log "Failed to mark GNU public GPG keys as ultimately trusted."
	exit 1
fi

log "GNU public GPG keyring setup successfully."
