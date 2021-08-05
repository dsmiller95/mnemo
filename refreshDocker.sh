#!/usr/bin/bash

if [[ -z "${LOCALAPPDATA}" ]]; then
  echo "the LOCALAPPDATA environment variable is undefined. aborting."
  exit 1
fi

mkdir -p "$LOCALAPPDATA/Mnemo"

docker build -t dnam/mnemo .&& \
(docker stop mnemo-server && \
docker rm mnemo-server || echo "no existing server") && \
docker run -t -d \
 --name=mnemo-server \
 --restart=no \
 -p 8080:80 \
 --volume "$LOCALAPPDATA/Mnemo":/home/mnemo_ops \
 dnam/mnemo