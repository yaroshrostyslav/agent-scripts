#!/bin/bash

# Monitor CPU frequency, temperature and throttle status in real time.
# Usage: bash cpu-monitor.sh [interval_seconds]
# Default interval: 2s. Press Ctrl+C to stop.

INTERVAL=${1:-2}

printf "%-20s %8s %8s %8s %8s  %s\n" "time" "cpu0" "cpu1" "cpu2" "cpu3" "temp  throttled"
printf "%-20s %8s %8s %8s %8s  %s\n" "----" "----" "----" "----" "----" "----  ---------"

while true; do
    ts=$(date "+%H:%M:%S")
    freqs=()
    for cpu in 0 1 2 3; do
        hz=$(cat /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
        freqs+=( $(awk "BEGIN{printf \"%.0fMHz\", $hz/1000}") )
    done
    temp=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2)
    throttled=$(vcgencmd get_throttled 2>/dev/null | cut -d= -f2)
    printf "%-20s %8s %8s %8s %8s  %s  %s\n" \
        "$ts" "${freqs[0]}" "${freqs[1]}" "${freqs[2]}" "${freqs[3]}" "$temp" "$throttled"
    sleep "$INTERVAL"
done