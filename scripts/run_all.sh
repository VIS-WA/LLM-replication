#!/bin/bash

## Execute from LLM-replication/scripts folder
## Purpose: Run all the models in the models directory 10 times and save the results in the benchmarks folder

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


# create benchmark folder if it does not exist:
mkdir -p benchmarks

#===================================================================================================
# run for all the models in the directory
for model_name in $(ls $model_dir); do
    echo ""
    echo "==================================================================================================="
    echo "Selected model: $model_name"
    # print path to model
    echo "Path to model: $model_dir/$model_name"

    # run the model for 10 times
    for it in {1..10}; do
        sleep 1
        echo ""
        echo "Iteration $it"
        # execute the model with nproc - 2 threads
        echo "Executing $model_name with $num_threads thread(s)"

        echo "Process ID: $$"
        # start the ram.sh script in background to monitor the memory usage
        ./ram.sh &
        echo "Background process ID: $!"
        # if ctrl+c is pressed, kill the background process
        trap "kill $!" EXIT


        ../llama.cpp/main -t $num_threads --no-mmap -n $OUTPUT_TOKENS  -m "$model_dir/$model_name" --color -c 2048 --temp $TEMP -p "$PROMPT" 2> benchmarks.txt 

        # if the model is not found, print error message and exit
        if [ $? -eq 1 ]; then
            echo "model execution error, exiting..."
            # print the last line from benchmarks.txt file
            tail -n 1 benchmarks.txt
            exit 1
        fi

        max_memory_used=$(cat max_memory.txt)
        echo ""
        echo "Maximum memory used: $max_memory_used MB"

        # echo ""
        #=========================================================

        
        #===================================================================================================
        # refine the log file to extract the timings
        echo "Refining the log file to extract the timings"
        results_file="benchmarks/$model_name/run_$it.txt"
        ./extract.sh $model_name $results_file
        echo "Timings extracted and benchmarks file updated in Benchmarks folder."

    done
done
# kill the free command running in background




