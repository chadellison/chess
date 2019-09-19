#!/bin/sh

if [ -d data ]
then
  sudo rm -rf data
  docker-compose rm -f
fi

docker-compose -f docker-compose.digital-ocean.yml up
