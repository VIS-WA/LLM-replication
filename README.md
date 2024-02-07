# LLM-replication

This repo contains the scripts to run the LLM model on a device. Currently this repo supports only Linux-based OS and is being used for internal puporses only.

## Files Description
1. `models_list.csv`: This file contains the list of available models that can be downloaded from the `model.sh` script. Update this with other models.
2. `model.sh`: Script to download an LLM model's weights. List of available models [here](models_list.csv).
3. `setup.sh`: Script to install [`llama.cpp`](https://github.com/ggerganov/llama.cpp). This is used to run the above downloaded models.
4. `run.sh`: Script to run the LLM model on a device and log the benchmarks. This script can be executed after completing the setup steps mentioned above.
5. `run_all.sh`: Script to run all the downloaded models (located in models/) and log the benchmarks.
6. `t_run.sh`: Script to benchmark the time taken to execute a selected model with a variable number of processor threads (from 1 to the maximum number of threads) and store the results in a file.
7. `plotter.py`: Python script to plot the results of various benchmarks including prompt eval timing, eval timing, memory usage, and time consumed with varying threads.


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
     chmod +x run.sh
  ```
   
4. Setup `llama.cpp` 
  ```
     ./setup.sh 
  ```
5. Download the required models
   ```
   ./model.sh
   ```
6. Run the script to select and execute an LLM model and save the benchmarks
   ```
   ./run.sh
   ```




## Things to Do:
- [x] Create script to run a model and log the benchmarks
- [ ] Merge individual scripts to a single master script
- [ ] create supporting scripts for Windows OS (Latte Panda)
- [x] Create scripts for downloading the models and setting up the environment
