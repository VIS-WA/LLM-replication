#!/bin/bash

## Execute from the LLM-replication/script folder
## Purpose: Run a single model and save the results in the benchmarks folder
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


# num_threads=$(nproc --all)
# num_threads=2

echo "Selected model: $model_name"
# print path to model
echo "Path to model: $model_dir/$model_name"

#===================================================================================================
# Model Execution
echo "Executing $model_name with $num_threads thread(s)"
# print current process ID
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
# refine the log file to extract the timings
echo "Refining the log file to extract the timings"
results_file="../benchmarks/$DEVICE/$model_name.txt"
./extract.sh $model_name $results_file
echo "Timings extracted and benchmarks file updated in Benchmarks folder."


