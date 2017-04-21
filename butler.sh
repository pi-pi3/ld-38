#!/usr/bin/env sh

push() {
    GAME=$1;
    VERSION=$2;
    ITCH=$3;
    LINUX_PATH=$4;
    WINDOWS_PATH=$5;
    MAC_PATH=$6;

    echo "Pushing $GAME to $ITCH.itch.io/$GAME using butler...";
    butler push release/$GAME.love  $ITCH/$GAME:src   --userversion $VERSION;
    butler push $LINUX_PATH         $ITCH/$GAME:linux --userversion $VERSION;
    butler push $WINDOWS_PATH       $ITCH/$GAME:win   --userversion $VERSION;
    butler push $MAC_PATH           $ITCH/$GAME:mac   --userversion $VERSION;
    echo "Done.";
}

push $1 $2 $3 $4 $5 $6
