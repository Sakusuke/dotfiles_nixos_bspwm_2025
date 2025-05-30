#!/usr/bin/env bash

DIR="$HOME/.config/polybar"
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar bottom -c "$DIR"/config.ini &
