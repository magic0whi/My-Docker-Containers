#!/bin/sh
for dir in *
do
    pushd $dir
    docker-compose down
    popd
done
