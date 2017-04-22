#!/usr/bin/sh
DIR="$(dirname "${BASH_SOURCE[0]}")"
GAME="ld-38"
love "$DIR/$GAME.love"
