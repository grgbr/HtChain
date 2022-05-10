#!/bin/sh -e

addgroup --gid $HTCHAIN_GID $HTCHAIN_GROUP
adduser --uid $HTCHAIN_UID \
        --gid $HTCHAIN_GID \
        --home $HTCHAIN_HOME \
        --no-create-home \
        --disabled-password \
        --gecos '' \
        $HTCHAIN_USER
adduser $HTCHAIN_USER htchain
adduser $HTCHAIN_USER sudo

if [ $# -eq 0 ]; then
	exec runuser --login $HTCHAIN_USER
else
	exec runuser --login $HTCHAIN_USER --command="$*"
fi
