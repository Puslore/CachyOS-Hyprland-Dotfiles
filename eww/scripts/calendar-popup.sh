#!/bin/bash

# Toggle calendar popup
if [ "$1" = "toggle" ]; then
  if eww windows | grep -q "calendar-popup"; then
    eww close calendar-popup
  else
    # Update content before showing
    DATE=$(date '+%a, %d %b %Y')
    TIME=$(date '+%H:%M:%S')
    MONTH_YEAR=$(date '+%B %Y')
    
    # Update the window with current date/time/month-year
    eww update current-date="$DATE" 
    eww update current-time="$TIME"
    eww update month-year="$MONTH_YEAR"
    eww open calendar-popup
  fi
fi