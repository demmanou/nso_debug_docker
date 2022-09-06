#!/bin/sh

status=$(docker cp $TEMP_CONTAINER_NAME:/tmp/$NEW_PACKAGE_NAME ./packages)
echo "Created new package!"
