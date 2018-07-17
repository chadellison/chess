# README

[Production](https://chess-machine.herokuapp.com)

## Realtime Chess with Rails 5 Action Cable!

This API serves data to a [react client.](https://github.com/chadellison/chessClient)
allowing users to play live chess with websockets. Users can play with other users, AI Players, or observe Ai players. This chess AI leverages machine learning to make
intelligent moves. This AI uses professional chess matches (in pgn format),
self-play, and the stockfish chess engine (an open source chess engine) to train
and analyze the results of games.

![Game Play](http://www.giphy.com/gifs/wHd7oVPymSwssLy0pT.gif)
![Game Play](https://giphy.com/gifs/wHd7oVPymSwssLy0pT/fullscreen.gif)
* Ruby version: 2.5.0
* Rails version: 5.2.0

* Database
```rails db:create```
```rails db:migrate```

* The test suite can be run with:
```rspec```
