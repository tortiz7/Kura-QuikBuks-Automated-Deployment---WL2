#!/bin/bash

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
cpu_threshold=75.0

# Check Memory usage
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
mem_threshold=90.0

# Check Disk usage
disk_usage=$(df -h / | grep / | awk '{print $5}' | sed 's/%//g')
disk_threshold=90

# Output and check CPU usage
echo "CPU Usage: $cpu_usage%"
if (( $(echo "$cpu_usage > $cpu_threshold" |bc -l) )); then
    echo "Warning: High CPU usage!"
    exit 1
fi

# Output and check Memory usage
echo "Memory Usage: $mem_usage%"
if (( $(echo "$mem_usage > $mem_threshold" |bc -l) )); then
    echo "Warning: High Memory usage!"
    exit 1
fi

# Output and check Disk usage
echo "Disk Usage: $disk_usage%"
if [ $disk_usage -gt $disk_threshold ]; then
    echo "Warning: High Disk usage!"
    exit 1
fi

echo "System resources are within normal limits."
exit 0
