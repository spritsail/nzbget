#! /bin/sh

if [ ! -f /config/nzbget.conf ]; then
	cp  /nzbget/nzbget.conf /config/nzbget.conf
	echo "Created Config File"
fi

/nzbget/nzbget -c /config/nzbget.conf -s -o OutputMode=log
