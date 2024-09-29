#!/bin/bash

DATAFOLDER=data
ORIGDATAFOLDER=data.orig
DATAFILES="$(ls ./$ORIGDATAFOLDER)"
echo checking if exist files of $DATAFOLDER folder
for DATAFILE in ${DATAFILES}; do
	echo checking if exist $DATAFILE
	if [ ! -f ./$DATAFOLDER/$DATAFILE ]; then
		echo copy orig $DATAFILE to $DATAFOLDER folder
		cp -a ./$ORIGDATAFOLDER/$DATAFILE ./$DATAFOLDER/$DATAFILE
	fi
done

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

exec "$@"
