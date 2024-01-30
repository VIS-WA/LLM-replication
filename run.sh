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

echo "Executing $model_name with $(nproc --all) thread(s)"
./llama-cpp/main -t $(nproc --all) -n 16  -m "$model_dir/$model_name" --color -c 2048 --temp 0.5 -p "Building a website can be done in 10 simple steps:\nStep 1:" 2> benchmarks.txt 

echo "Benchmark results saved in benchmarks.txt"

