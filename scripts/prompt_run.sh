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
# mkdir -p "../benchmarks/$model_name/prompts"

# print path to model
echo "Path to model: $model_dir/$model_name"


# different prompts are stored in a text file with each prompt in a new line. Load them into an array
prompts=()
while IFS= read -r line; do
    prompts+=("$line")
done < "../prompt.txt"



#===================================================================================================
x=0
echo "Running the model with ${#prompts[@]} prompts"
# iterate through the different prompts
for prompt in "${prompts[@]}"; do
    # remove any trailing spaces and trailing special characters from the prompt
    prompt=$(echo $prompt | sed 's/[[:space:]]*$//')
    echo "Executing $model_name with $num_threads thread(s)"
    x=$((x+1))
    
    # print current process ID
    echo "Process ID: $$"
    # start the ram.sh script in background to monitor the memory usage
    ./ram.sh &
    # print the process ID of the background process
    echo "Background process ID: $!"
    # if ctrl+c is pressed, kill the background process
    trap "kill $!" EXIT

    echo "Running the model with the following prompt:"
    echo "$prompt"
    # ./llama.cpp/main -t $num_threads --no-mmap -n 16  -m "$model_dir/$model_name" --color -c 2048 --temp 0.5 -p "Building a website can be done in 10 simple steps:\nStep 1:" 2> benchmarks.txt 
    ../llama.cpp/main -t $num_threads --no-mmap -n $OUTPUT_TOKENS  -m "$model_dir/$model_name" --color -c 2048 --temp $TEMP -p "$prompt" 2> benchmarks.txt

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
    results_file="benchmarks/$model_name/prompts/$x.txt"
    echo "Refining the log file to extract the timings"
    ./extract.sh $model_name $results_file
    echo "Timings extracted and benchmarks file updated in Benchmarks folder."
    echo ""

done

