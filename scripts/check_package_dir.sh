#!/bin/sh

DIR=./packages

if [ "$(ls $DIR)" ]; then
    echo "Found packages!"
else
    echo "No packages found!"
    exit 1
fi
