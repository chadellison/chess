#!/bin/sh

echo "sleeping for $1 seconds"

/bin/sleep $1

echo 'performing operations'

echo 'SETTING UP DB'
rake db:setup

echo 'SETTING UP WEIGHTS'
rake initialize_weights

echo 'LOADING CHESS GAMES'
rake load_chess_games
