#!/bin/bash

# This script will be executed from the LLM-replication folder

model_dir="./models"
# check if model_dir directory exists, if it exists, print it is found and if not ask user to enter the path to the directory
if [ -d "$model_dir" ]; then
    echo "Model directory found"
else
    echo "Model directory not found, please enter the path to the directory"
    read model_dir
fi


# print the models in the directory with serial number and ask user to select one with serial number and save the corresponding model name in model_name variable
echo "Please select a model from the list below by entering the serial number"
# save the models in the directory in a variable
models=$(ls $model_dir)
# print the models in the directory with serial number
for i in $(seq 1 $(ls $model_dir | wc -l)); do
    echo "$i) $(ls $model_dir | sed -n "$i"p)"
done
# ask user to select one with serial number
read model_serial
# save the corresponding model name in model_name variable 
model_name=$(ls $model_dir | sed -n "$model_serial"p)

echo "Selected model: $model_name"


# print path to model
echo "Path to model: $model_dir/$model_name"

#===================================================================================================
echo "Executing $model_name with $(nproc --all) thread(s)"
./llama.cpp/main -t $(nproc --all) -n 16  -m "$model_dir/$model_name" --color -c 2048 --temp 0.5 -p "Building a website can be done in 10 simple steps:\nStep 1:" 2> benchmarks.txt 

# if the model is not found, print error message and exit
if [ $? -eq 1 ]; then
    echo "model execution error, exiting..."
    exit 1
fi


echo ""
echo "Benchmark results saved in benchmarks.txt"

#===================================================================================================
# refine the log file to extract the timings

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
mv "$temp_file" "$log_file"

# if any error occurs, print error message and exit
if [ $? -eq 1 ]; then
    echo "benchmarking error, exiting..."
    exit 1
fi
echo "Timings extracted and log file updated."


