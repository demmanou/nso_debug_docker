#!/bin/sh

if [[ $ARE_PACKAGES = TRUE ]]; then
    echo "Compiling packages..."
    docker exec -it $CONTAINER_NAME bash -c '. /opt/ncs/current/ncsrc \
        && for d in /var/opt/ncs/packages/*/; do make clean all -C $d/src; done' > /dev/null 2>&1
    echo "Reloading packages..."
    docker exec -it $CONTAINER_NAME bash -c 'su - nsoadmin -c "source /opt/ncs/current/ncsrc \
       && echo packages reload force | ncs_cli -C"' > /dev/null 2>&1
else
    echo "No packages found..."
fi
