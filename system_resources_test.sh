#!/bin/bash

# The below will calculate the cpu usage. "top -bn1" runs the top command once and provides the output for system resources. then we pipe that output into a grep to isolate just the cpu usage. Finally, we add the 2nd and 4th columns, the User CPU Usage and System CPU Usage respectfully, to get the total cpu usage: awk '(print $2 + $4)'
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
cpu_threshold=75.0

# The below calculates memory usage. "free" gives systme mem usage. pipe that into "grep mem" to filter just the line containing mem stats. Pipe that into "awk '{print $3/$2 * 100} to divide the used mem by total mem, then multiples by 100, giving us our mem usage percentage.  
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
mem_threshold=90.0

# The below calculate disk usage. "df -h /" dispalys disk usage for root directory in human-readable format. pipe that into "grep /" to get the line that shows just disk usage in root dir. pipe that into awk '{print $5} to get just the column w/ percetnage of used disk space. Final pipe into "sed 's/%'g'" to remove the percent sign so we're left with just the number for the output
disk_usage=$(df -h / | grep / | awk '{print $5}' | sed 's/%//g')
disk_threshold=90

# Below checks CPU usage aainst the threshold. "bc -1" uses basic calculator to perform the comparison, with the flag allowing floating point calculations. Exit 1 is our error flag, which Jenkins will interpret and result in a failed test stage if triggerd. 
echo "CPU Usage: $cpu_usage%"
if (( $(echo "$cpu_usage > $cpu_threshold" |bc -l) )); then
    echo "Warning: High CPU usage!"
    exit 1
fi

# Below checks mem usage against the threshold, using the same conditional as the cpu usage above
echo "Memory Usage: $mem_usage%"
if (( $(echo "$mem_usage > $mem_threshold" |bc -l) )); then
    echo "Warning: High Memory usage!"
    exit 1
fi

# Below does the same as the other two, just for disk usage
echo "Disk Usage: $disk_usage%"
if [ $disk_usage -gt $disk_threshold ]; then
    echo "Warning: High Disk usage!"
    exit 1
fi

#exit 0 gives the all clear to Jenkins that all the tests passed, and we can move onto the deploy phase!
echo "System resources are within normal limits."
exit 0
