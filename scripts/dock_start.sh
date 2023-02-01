#!/bin/sh -e

addgroup --gid $HTCHAIN_GID $HTCHAIN_GROUP >/dev/null
adduser --uid $HTCHAIN_UID \
        --gid $HTCHAIN_GID \
        --home $HTCHAIN_HOME \
        --no-create-home \
        --disabled-password \
        --gecos '' \
        $HTCHAIN_USER >/dev/null
adduser $HTCHAIN_USER htchain >/dev/null
adduser $HTCHAIN_USER sudo >/dev/null

if [ $# -eq 0 ]; then
	exec setpriv --inh-caps=-all \
	             --ambient-caps=-all \
	             --reset-env \
	             -- /sbin/runuser --login $HTCHAIN_USER
else
	exec setpriv --inh-caps=-all \
	             --ambient-caps=-all \
	             --reset-env \
	             -- /sbin/runuser --login $HTCHAIN_USER --command="$*"
fi
