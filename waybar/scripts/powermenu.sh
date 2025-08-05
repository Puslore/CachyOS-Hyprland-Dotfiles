#!/bin/bash


chosen=$(echo -e "Lock\nLogout\nShutdown\nReboot\nSleep\nHibernate" | wofi --dmenu --insensitive --width 250 --height 250 --cache-file /dev/null)

case "$chosen" in
    "Lock") hyprlock ;;
    "Logout") hyprctl dispatch exit ;;
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Sleep") systemctl suspend ;;
    "Hibernate") systemctl hibernate ;;
esac
