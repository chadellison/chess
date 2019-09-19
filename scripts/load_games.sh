#!/bin/sh

rake db:create;
rake db:migrate;
rake load_chess_games;
