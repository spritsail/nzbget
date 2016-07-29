#! /bin/sh

if [ ! -f /config/nzbget/nzbget.conf ]; then
	cp  /nzbget/nzbget.conf /config/nzbget/nzbget.conf
	echo "Created Config File"
fi

/nzbget/nzbget -c /config/nzbget/nzbget.conf -s -o OutputMode=log
