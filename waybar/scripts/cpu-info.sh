#!/usr/bin/env bash

# Get CPU model (removed "(R)", "(TM)", and clock speed)
model=$(awk -F ': ' '/model name/{print $2}' /proc/cpuinfo | head -n 1 | sed 's/@.*//; s/ *\((R)\|(TM)\)//g; s/^[ \t]*//; s/[ \t]*$//')

# Get CPU usage percentage
load=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

# Determine CPU state based on usage
if [ "$load" -ge 80 ]; then
  state="Critical"
elif [ "$load" -ge 60 ]; then
  state="High"
elif [ "$load" -ge 25 ]; then
  state="Moderate"
else
  state="Low"
fi

# Get CPU clock speeds
get_cpu_frequency() {
  freqlist=$(awk '/cpu MHz/ {print $4}' /proc/cpuinfo)
  maxfreq=$(sed 's/...$//' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
  average_freq=$(echo "$freqlist" | tr ' ' '\n' | awk "{sum+=\$1} END {printf \"%.0f/%s MHz\", sum/NR, $maxfreq}")
  echo "$average_freq"
}

# Get CPU temperature
get_cpu_temperature() {
  temp=$(sensors | awk '/Package id 0/ {print $4}' | awk -F '[+.]' '{print $2}')
  if [[ -z "$temp" ]]; then
    temp=$(sensors | awk '/Tctl/ {print $2}' | tr -d '+°C')
  fi
  if [[ -z "$temp" ]]; then
    temp="N/A"
  else
    temp_f=$(awk "BEGIN {printf \"%.1f\", ($temp * 9 / 5) + 32}")
  fi
  echo "${temp:-N/A} ${temp_f:-N/A}"
}

# Get the corresponding icon based on temperature
get_temperature_icon() {
  temp_value=$1
  if [ "$temp_value" -ge 80 ]; then
    icon="󰸁" # High temperature
  elif [ "$temp_value" -ge 70 ]; then
    icon="󱃂" # Medium temperature
  elif [ "$temp_value" -ge 60 ]; then
    icon="󰔏" # Normal temperature
  else
    icon="󱃃" # Low temperature
  fi
  echo "$icon"
}

# Main script execution
cpu_frequency=$(get_cpu_frequency)
read -r temp_info < <(get_cpu_temperature)
temp=$(echo "$temp_info" | awk '{print $1}')   # Celsius
temp_f=$(echo "$temp_info" | awk '{print $2}') # Fahrenheit

# Set color for load based on CPU load
if [ "$load" -ge 80 ]; then
  # If CPU usage is >= 80%, set color to #f38ba8
  load_part="<span color='#f38ba8'>${load}%</span>"
else
  # Default color
  load_part="${load}%"
fi

# Set color for temperature based on temperature value
if [ "$temp" -ge 80 ]; then
  # If temperature is >= 80%, set color to #f38ba8
  temp_part="<span color='#f38ba8'>${temp}</span>"
else
  # Default color
  temp_part="${temp}"
fi

# Combine outputs in the requested format
combined_text="${load_part}/${temp_part}"

# Combined tooltip
tooltip="${model}\nCPU Usage: ${state}\nTemperature: ${temp_f}°F\nClock Speed: ${cpu_frequency}"

# Output JSON for Waybar
echo "{\"text\": \"$combined_text\", \"tooltip\": \"$tooltip\"}"
