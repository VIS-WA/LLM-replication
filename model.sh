#!/bin/bash

# get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# download a text file using curl without any output
# curl -s -o $DIR/models_list.txt https://raw.githubusercontent.com/VIS-WA/LLM-replication/main/models_list.csv

# print the first two columns of the text file with a separation of 2 tabs
awk -F, '{print "\n" $1 "\t" $2}' models_list.csv

# user input for a number
echo -e "\n"
echo "Enter the S.No of the model to be downloaded: "

read model_no

#add 1 to the user input
model_no=$((model_no+1))
model_name=$(awk -F, -v var="$model_no" 'NR==var {print $2}' models_list.txt)
# fetch the url of the model corresponding to the S.No in column 3
model_url=$(awk -F, -v var="$model_no" 'NR==var {print $3}' models_list.txt)


# print message that name of the model being downloaded
echo "Downloading $model_name..."
# echo $model_url
# echo "$DIR/$model_name.gguf"
# download the model
curl -L -o "$DIR/$model_name.gguf" $model_url
