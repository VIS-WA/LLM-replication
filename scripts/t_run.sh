#!/bin/bash

## Execute from the LLM-replication/script folder
## Purpose: Run the chosen model with 1 to max threads and save the benchmark results in a file
#===================================================================================================
# Device Parameters
CONFIG_FILE="../config.txt"
source $CONFIG_FILE

# check if model_dir directory exists, if it exists, print it is found and if not ask user to enter the path to the directory
if [ -d "$model_dir" ]; then
    echo "Model directory found"
else
    echo "Model directory not found, please enter the path to the directory"
    read model_dir
fi

echo "Please select a model from the list below by entering the serial number"
models=$(ls $model_dir)
for i in $(seq 1 $(ls $model_dir | wc -l)); do
    echo "$i) $(ls $model_dir | sed -n "$i"p)"
done
read model_serial
model_name=$(ls $model_dir | sed -n "$model_serial"p)

echo "Selected model: $model_name"
echo "Path to model: $model_dir/$model_name"

#===================================================================================================
# iterate through the number of threads from 1 to max threads and run the model with each number of threads
for num_threads in $(seq 1 $(nproc --all)); do
    echo "Executing $model_name with $num_threads thread(s)"
    echo "Process ID: $$"
    # start the ram.sh script in background to monitor the memory usage
    ./ram.sh &
    # print the process ID of the background process
    echo "Background process ID: $!"
    # if ctrl+c is pressed, kill the background process
    trap "kill $!" EXIT

    ../llama.cpp/main -t $num_threads --no-mmap -n $OUTPUT_TOKENS  -m "$model_dir/$model_name" --color -c 2048 --temp $TEMP -p "$PROMPT" 2> benchmarks.txt 

    # if the model is not found, print error message and exit
    if [ $? -eq 1 ]; then
        echo "model execution error, exiting..."
        exit 1
    fi

    max_memory_used=$(cat max_memory.txt)
    echo ""
    echo "Maximum memory used: $max_memory_used MB"

    #===================================================================================================
    results_file="../benchmarks/$DEVICE/$model_name/threads/$num_threads.txt"
    # refine the log file to extract the timings
    echo "Refining the log file to extract the timings"
    ./extract.sh $model_name $results_file
    echo "Timings extracted and benchmarks file updated in Benchmarks folder."

done

