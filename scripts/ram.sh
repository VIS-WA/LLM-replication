#!/bin/bash

# Set the path to the max_memory.txt file
max_memory_file="max_memory.txt"

# Get the process ID of the parent process that spawned this script
parent_pid=$PPID

# Initialize the maximum memory variable
max_memory=0

# Infinite loop to monitor the memory usage
while true; do
    # Get all PIDs of the parent process and its child processes
    pids=$(pstree -p $parent_pid | grep -oP '\(\K\d+')

    # Initialize variable to sum up the memory usage of all these processes
    total_memory=0

    # Loop through all PIDs and sum their memory usage
    for pid in $pids; do
        mem=$(ps -o rss= -p $pid 2>/dev/null | awk '{s+=$1} END {print s}')
        total_memory=$((total_memory + mem))
    done

    # echo "Total memory usage: $((total_memory / 1024)) MB, Process ID: $$"

    # Check if the total memory usage is greater than the maximum memory
    if [[ $total_memory -gt $max_memory ]]; then
        max_memory=$total_memory
    fi

    # Update the max_memory.txt file with the maximum memory usage
    echo $((max_memory / 1024)) > $max_memory_file

    # Sleep for 0.1 seconds
    sleep 0.1
done
