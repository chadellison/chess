#!/bin/sh

PG_HOST=db

rake db:create;
rake db:migrate;
rake load_chess_games;
