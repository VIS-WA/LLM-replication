#!/bin/bash

## This script will be executed from the LLM-replication folder

model_dir="./models"
# check if model_dir directory exists, if it exists, print it is found and if not ask user to enter the path to the directory
if [ -d "$model_dir" ]; then
    echo "Model directory found"
else
    echo "Model directory not found, please enter the path to the directory"
    read model_dir
fi


# # print the models in the directory with serial number and ask user to select one with serial number and save the corresponding model name in model_name variable
# echo "Please select a model from the list below by entering the serial number"
# # save the models in the directory in a variable
# models=$(ls $model_dir)
# # print the models in the directory with serial number
# for i in $(seq 1 $(ls $model_dir | wc -l)); do
#     echo "$i) $(ls $model_dir | sed -n "$i"p)"
# done
# # ask user to select one with serial number
# read model_serial

# # save the corresponding model name in model_name variable 
# model_name=$(ls $model_dir | sed -n "$model_serial"p)

# echo "Selected model: $model_name"
# # print path to model
# echo "Path to model: $model_dir/$model_name"

# # set max_memory_used variable to 1 TB
# max_memory_used=1048576 # 1 TB -> large value



# create benchmark folder if it does not exist:
mkdir -p benchmarks
# start timer 
initial_start=$(date +%s.%N)

#===================================================================================================
# run for all the models in the directory
for model_name in $(ls $model_dir); do
    echo ""
    echo "==================================================================================================="
    echo "Selected model: $model_name"
    # print path to model
    echo "Path to model: $model_dir/$model_name"
    start=$(date +%s.%N)
    # create directory with the model name if it does not exist:
    mkdir -p "benchmarks/$model_name"
    # run the model for 10 times
    for it in {1..10}; do
        sleep 1
        echo ""
        echo "Iteration $it"
        pwd
        echo "Executing $model_name with $(nproc --all) thread(s)"

        # store the initial free memory
        initial_free_memory=$(free -m | awk '/^Mem/ {printf "%d\n", $7}')
        # initial_free_memory=$(( $(wmic computersystem get TotalPhysicalMemory | grep -oP '\d+') / 1024 )) # for windows
        echo "Initial free memory: $initial_free_memory MB"

        # store maximum memory used by the model
        max_memory_used=$initial_free_memory

        ## Background process to monitor the memory usage
        while true; do
            free_memory=$(free -m | awk '/^Mem/ {printf "%d\n", $7}') # for linux
            # free_memory = $(( $(wmic computersystem get TotalPhysicalMemory | grep -oP '\d+') / 1024 )) # for windows

            # echo "Free memory: $free_memory MB, Max memory used: $max_memory_used MB"
            if [ $max_memory_used -gt $free_memory ]; then
                max_memory_used=$free_memory
            fi
            # write the maximum memory used by the model to a file
            echo "$max_memory_used" > max_memory_used.txt
            sleep 0.1
        done &

        ./llama.cpp/main -t $(nproc --all) --no-mmap -n 16  -m "$model_dir/$model_name" --color -c 2048 --temp 0.5 -p "Building a website can be done in 10 simple steps:\nStep 1:" 2> benchmarks.txt 

        # if the model is not found, print error message and exit
        if [ $? -eq 1 ]; then
            echo "model execution error, exiting..."
            # print the last line from benchmarks.txt file
            tail -n 1 benchmarks.txt
            exit 1
        fi
        # print the maximum memory used by the model which is srored in max_memory_used variable of the background process
        # cat max_memory_used.txt
        max_memory_used=$(cat max_memory_used.txt)
        echo ""
        echo "Minimum available memory: $max_memory_used MB"
        echo "Maximum memory used: $((initial_free_memory - max_memory_used)) MB"

        kill $!

        # echo ""
        #===================================================================================================
        # refine the log file to extract the timings

        log_file="benchmarks.txt"
        temp_file="temp_log_file.txt"
        results_file="benchmarks/$model_name/run_$it.txt"
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

        # Replace the original log file with the temporary file
        mv "$temp_file" "$results_file"

        # append the maximum memory used by the model to the benchmarks file
        echo "Maximum memory used: $((initial_free_memory - max_memory_used)) MB" >> "$results_file"

        # if any error occurs, print error message and exit
        if [ $? -eq 1 ]; then
            echo "benchmarking error, exiting..."
            exit 1
        fi
        echo "Timings extracted and benchmarks file updated in Benchmarks folder."

        end=$(date +%s.%N)
        echo "Time elapsed for this model: $(echo "$end - $start" | bc) seconds"

    done
done
# kill the free command running in background
# remove the file that stores the maximum memory used by the model
rm max_memory_used.txt
# print total time elapsed
final_end=$(date +%s.%N)
echo "Total time elapsed: $(echo "$final_end - $initial_start" | bc) seconds"




