#!/usr/bin/env bash

config="$HOME/.config/rofi/power-menu.rasi"

actions=$(echo -e "  Lock\n  Shutdown\n  Reboot\n  Suspend\n  Hibernate\n  Logout")

# Display logout menu
selected_option=$(echo -e "$actions" | rofi -dmenu -i -config "${config}" || pkill -x rofi)

#!/bin/bash
rofi -dmenu -p "Power Options" -theme ~/.config/rofi/your-theme.rasi

# Perform actions based on the selected option
case "$selected_option" in
*Lock)
  hyprlock
  ;;
*Shutdown)
  systemctl poweroff
  ;;
*Reboot)
  systemctl reboot
  ;;
*Suspend)
  systemctl suspend
  ;;
*Hibernate)
  systemctl hibernate
  ;;
*Logout)
  hyprctl dispatch exit 0
  ;;
esac
