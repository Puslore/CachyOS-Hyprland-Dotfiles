#!/bin/bash

DIR="$HOME/Pictures/Screenshots"

mkdir -p "$DIR"

FILENAME="$DIR/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"

grim "$FILENAME"

grim - | wl-copy

notify-send "Screenshot saved~~~"
