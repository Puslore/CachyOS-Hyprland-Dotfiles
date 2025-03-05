#!/bin/bash

DIR="$HOME/Screenshots"

mkdir -p "$DIR"

FILENAME="$DIR/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"

grim -g "$(slurp)" "$FILENAME" && wl-copy < "$FILENAME"

notify-send "Screenshot saved~~~"
