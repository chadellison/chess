#!/bin/sh

echo "sleeping for $1 seconds"

/bin/sleep $1

echo 'performing operations'

PG_HOST=$2 rake db:create;
PG_HOST=$2 rake db:migrate;
PG_HOST=$2 rake load_chess_games;

