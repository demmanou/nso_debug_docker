#!/bin/sh

echo "Starting NSO..."
docker exec -it $CONTAINER_NAME bash -c '/etc/init.d/ncs start' || exit
