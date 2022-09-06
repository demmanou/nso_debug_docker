#!/bin/sh

status=$(docker exec -it $CONTAINER_NAME bash -c '/etc/init.d/ncs status')
while [[ "$status" == *"refused"* ]]; do
    echo "NSO not started yet! Trying again in 3 seconds..."
    sleep 3
    status=$(docker exec -it $CONTAINER_NAME bash -c '/etc/init.d/ncs status')
done
echo "NSO ready!"
