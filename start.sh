#!/bin/sh
set -e

conf_file="/config/nzbget.conf"

if [ ! -f "$conf_file" ]; then
	cp /nzbget/nzbget.conf $conf_file
	echo "Created default config file at $conf_file"
fi

# Ensure nzbget directory is writeable by the running user
chown -R $UID:$GID /nzbget

exec su-exec $UID:$GID $@
