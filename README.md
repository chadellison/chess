# README

[Production](https://chess-machine.herokuapp.com)

## Realtime Chess with Rails 5 Action Cable!

This API serves data to a [react client](https://github.com/chadellison/chessClient)
allowing users to play live chess with websockets. Users can play with other users, AI Players, or observe Ai players. The AI leverages a neural network to make
intelligent moves. This AI uses professional chess matches (in pgn format),
self-play, and the stockfish chess engine (an open source chess engine) to train
and analyze the results of games.

- Ruby version: 2.5.0
- Rails version: 5.2.0

- Database
  `rails db:create`
  `rails db:migrate`

- The test suite can be run with:
  `rspec`

rake:

1. load_chess_games
1. initialize_weights
1. train_with_abstractions
1. export_weights
