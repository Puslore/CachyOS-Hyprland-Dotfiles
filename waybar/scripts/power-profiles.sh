#!/bin/bash


chosen=$(echo -e "Performance\nBalanced\nPower-saver" | wofi --dmenu --insensitive --width 250 --height 160 --cache-file /dev/null)

case "$chosen" in
    "Performance") powerprofilesctl set performance ;;
    "Balanced") powerprofilesctl set balanced ;;
    "Power-saver") powerprofilesctl set power-saver ;;
esac
