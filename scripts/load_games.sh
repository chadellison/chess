#!/bin/sh

echo 'sleeping for 20 seconds'

/bin/sleep 20

echo 'performing operations'

PG_HOST=db rake db:create;
PG_HOST=db rake db:migrate;
PG_HOST=db rake load_chess_games;

