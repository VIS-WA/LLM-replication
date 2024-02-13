#!/bin/bash

# get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

# print the first two columns of the text file with a separation of 2 tabs
awk -F, '{print "\n" $1 "\t" $2}' $DIR/models_list.csv

# user input for a number
echo -e "\n"
echo "Enter the S.No of the model to be downloaded (99 to download all the models): "

read model_num

# create a directory to save the model
mkdir -p ../models/

# if the user input is 99, download all the models
if [ $model_num -eq 99 ]; then
    echo "Downloading all the models..."
    # download all the models
    for i in $(seq 2 $(cat $DIR/models_list.csv | wc -l)); do
        model_no=$i
        model_name=$(awk -F, -v var="$model_no" 'NR==var {print $2}' $DIR/models_list.csv)
        # fetch the url of the model corresponding to the S.No in column 3
        echo "Downloading $model_name..."
        model_url=$(awk -F, -v var="$model_no" 'NR==var {print $3}' $DIR/models_list.csv)
        # download the model
        # echo $model_url
        wget -nc -P "$DIR/models/" "$model_url"
        # curl -L --create-dirs -O --output-dir "$DIR/models/" $model_url
    done
    exit 0
else 
# if the user input is not 99, download the model corresponding to the S.No
    #add 1 to the user input
    model_no=$((model_num+1))
    # fetch the name of the model corresponding to the S.No in column 2
    model_name=$(awk -F, -v var="$model_no" 'NR==var {print $2}' $DIR/models_list.csv)
    # fetch the url of the model corresponding to the S.No in column 3
    model_url=$(awk -F, -v var="$model_no" 'NR==var {print $3}' $DIR/models_list.csv)
    # print message that name of the model being downloaded
    echo "Downloading $model_name..."
    # download the model 
    # curl -L --create-dirs -O --output-dir "$DIR/models/" $model_url
    wget -nc -P "$DIR/models/" "$model_url"

    exit 0
fi
