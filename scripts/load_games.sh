#!/bin/sh

echo "sleeping for $1 seconds"

/bin/sleep $1

echo 'performing operations'

echo 'CREATING DB'
PG_HOST=$2 rake db:create || echo 'PROLLY FINE'

echo 'MIGRATING'
PG_HOST=$2 rake db:migrate || echo 'PROLLY FINE'

echo 'LOADING CHESS GAMES'
PG_HOST=$2 rake load_chess_games

