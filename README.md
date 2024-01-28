# LLM-replication

This repo contains the scripts to run the LLM model on a device. Currently this repo supports only Linux-based OS.

## Files Description
1. `model.sh`: Script to download an LLM model's weights. List of available models [here](models_list.csv)
2. `setup.sh`: Script to install [`llama.cpp`](https://github.com/ggerganov/llama.cpp). This is used to run the above downloaded models.

## Execution Steps:
1. Clone this repo 
  ```
     git clone https://github.com/VIS-WA/LLM-replication.git
  ```
2. Cd into the directory 
  ```
     cd LLM-replication 
  ```
   
3. Make the files executable 
  ```
     chmod +x setup.sh
     chmod +x model.sh 
  ```
   
4. Setup `llama.cpp` 
  ```
     ./setup.sh 
  ```
5. Download the required models
   ```
   ./model.sh
   ```


## Things to Do:
- [ ] Create script to run a model and log the benchmarks
- [ ] Merge individual scripts to a single master script
- [ ] create supporting scripts for Windows OS (Latte Panda)
- [x] Create scripts for downloading the models and setting up the environment
