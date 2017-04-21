#!/usr/bin/sh
DIR="$(dirname "${BASH_SOURCE[0]}")"
GAME="" #XXX
love "$DIR/$GAME.love"
