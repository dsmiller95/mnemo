#!/bin/bash

TIMESTAMP=`date +'%Y-%m-%d.%H%M'`

cd /usr/lib/cgi-bin

zip -r9 ~/mnemo-backup.$TIMESTAMP.zip mnemo mnemo_ops

