# README

[Production](https://chess-machine.herokuapp.com)

## Realtime Chess with Rails 5 Action Cable!

This API serves data to a [react client](https://github.com/chadellison/chessClient)
allowing users to play live chess with websockets. Users can play with other users, AI Players, or observe Ai players. The AI leverages a neural network to make
intelligent moves. This AI uses professional chess matches (in pgn format),
self-play, and the stockfish chess engine (an open source chess engine) to train
and analyze the results of games.

- Ruby version: 2.6.4
- Rails version: 5.2.3

- Database
  `rails db:create`
  `rails db:migrate`

- The test suite can be run with:
  `rspec`

## Training Locally

#### docker-compose

To spin up a Postgres Database and a Redis server simply:

`docker-compose up`

Make sure you do not have a `postgres`/`redis` server running on your local machine. As the ports will conflict.

Volumes for `postgres` and `redis` will be mounted in the repo with the same privelages as `docker`, which means `sudo`.

To compeltely wipe the `redis` and `postgres` volumes and containers you can do teh following in the root directory of this repo:

```bash
 docker-compose rm -f
```

If you need to wipe all data and start from scratch (bad migration/something went horribly wrong):

```
docker-compose rm -f
docker-compose pull
docker-compose up --build -d
```

#### rake

```bash
rake initialize_weights
rake load_chess_games
rake train_with_abstractions
rake export_weights
```
