#!/bin/bash

# recieve the model name from the parent script
model_name=$1
results_file=$2

# refine the log file to extract the timings
CONFIG_FILE="../config.txt"
source $CONFIG_FILE

mkdir -p $(dirname "$results_file")

log_file="benchmarks.txt"
temp_file="temp_log_file.txt"

# create a temporary file to save the extracted timings
touch "$temp_file"

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
mv "$temp_file" "$results_file"


# if any error occurs, print error message and exit
if [ $? -eq 1 ]; then
    echo "benchmarking error, exiting..."
    exit 1
fi
# echo file saved to $results_file
echo "Benchmarks to $results_file"

# remove the temporary file
rm "$log_file"
rm main.log
rm max_memory.txt