#!/bin/bash

# Description: Print the Raspberry Pi CPU temperature in degrees Celsius.
# Usage:
#   ./cpu-temp.sh          # prints e.g. "48.3"

# Prefer vcgencmd (most accurate on Raspberry Pi OS); fall back to sysfs.
if command -v vcgencmd >/dev/null 2>&1; then
    temp=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 | tr -d "'C")
elif [ -r /sys/class/thermal/thermal_zone0/temp ]; then
    milli=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp=$(awk "BEGIN{printf \"%.1f\", $milli/1000}")
else
    echo "Error: cannot read CPU temperature (no vcgencmd or thermal_zone0)." >&2
    exit 1
fi

echo "$temp"