#!/bin/sh

cd $HOME

if [ -f /usr/bin/stockfish ]
then
    echo 'no need to install'
    cd -
    exit 0
fi

wget https://stockfishchess.org/files/stockfish-10-linux.zip

unzip stockfish-10-linux.zip

chmod +x stockfish-10-linux/Linux/stockfish_10_x64

sudo mv stockfish-10-linux/Linux/stockfish_10_x64 /usr/bin/stockfish

rm -rf stockfish-10-linux.zip

rm -rf stockfish-10-linux

cd -
