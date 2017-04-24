#!/usr/bin/sh
DIR="$(dirname "${BASH_SOURCE[0]}")"
GAME="minor-madness"
love "$DIR/$GAME.love"
