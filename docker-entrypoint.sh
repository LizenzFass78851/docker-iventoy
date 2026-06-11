#!/bin/bash

set -e
set -u

DATAFOLDER=data
echo "checking if exist files of ${DATAFOLDER} folder"
for DATAFILE in $(find ./${DATAFOLDER} -type f -printf "%f\n"); do
    echo "checking if exist ${DATAFILE}"
    if [ ! -f ./${DATAFOLDER}/${DATAFILE} ]; then
        echo "copy orig ${DATAFILE} to ${DATAFOLDER} folder"
        cp -a ./${DATAFOLDER}{.orig,}/${DATAFILE}
    fi
done

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf "$@"
