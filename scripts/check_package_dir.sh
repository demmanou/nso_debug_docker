#!/bin/sh

DIR=./packages

if [ "$(ls $DIR)" ]; then
    echo TRUE
else
    echo FALSE
fi
