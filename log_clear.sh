#!/bin/bash

log_file="timings.txt"
temp_file="temp_log_file.txt"
found_timings=false
timings=()

while IFS= read -r line; do
    if [[ $line == "Log end" ]]; then
        break
    elif [[ $found_timings == true && $line == llama_print_timings:* ]]; then
        # Extract timings without the prefix
        timing_line="${line#llama_print_timings:}"
        timings+=("$timing_line")
    elif [[ $line == llama_print_timings:* ]]; then
        found_timings=true
    fi
done < "$log_file"

# Save the extracted timings to a temporary file
for timing in "${timings[@]}"; do
    echo "$timing" >> "$temp_file"
done

# Append the remaining lines (after 'Log end') to the temporary file
#sed -n '/Log end/,$p' "$log_file" >> "$temp_file"

# Replace the original log file with the temporary file
mv "$temp_file" "$log_file"

echo "Timings extracted and log file updated."

