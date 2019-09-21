#!/bin/sh

RAKE=$(docker ps --filter name=rake -q)

docker exec -it $RAKE /bin/sh
