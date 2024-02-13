# LLM-replication

This repo contains the scripts to run the LLM model on a device. Currently this repo supports only Linux-based OS and is being used for internal puporses only.

## Files Description
1. `models_list.csv`: This file contains the list of available models that can be downloaded from the `model.sh` script. Update this with other models.
2. `scripts/model.sh`: Script to download an LLM model's weights. List of available models [here](models_list.csv).
3. `setup.sh`: Script to install [`llama.cpp`](https://github.com/ggerganov/llama.cpp). This is used to run the above downloaded models.
4. `scripts/run.sh`: Script to run the LLM model on a device and log the benchmarks. This script can be executed after completing the setup steps mentioned above.
5. `scripts/run_all.sh`: Script to run all the downloaded models (located in models/) and log the benchmarks.
6. `scripts/t_run.sh`: Script to benchmark the time taken to execute a selected model with a variable number of processor threads (from 1 to the maximum number of threads).
7. `scripts/prompt_run.sh`: Script to benchmark the time taken to execute a selected model with a variable length of prompts as specified in the [`prompt.txt`](prompt.txt) file.
8. `scripts/plotter.py`: Python script to plot the results of various benchmarks including prompt eval timing, eval timing, memory usage, time consumed with varying threads and time consumed with varying prompts.


## Execution Steps:
1. Clone this repo 
   ```
      git clone https://github.com/VIS-WA/LLM-replication.git
   ```
2. Cd into the directory 
   ```
      cd LLM-replication 
   ```
   
3. Make the setup file executable 
   ```
      chmod +x setup.sh
   ```
   
4. Setup `llama.cpp` and make other scripts executable by running the setup script
   ```
      ./setup.sh 
   ```
5. Setup the device and model parameters in the [`config.txt`](config.txt)
5. cd into scripts directory
   ```
      cd scripts
   ``` 
6. Download the required models
   ```
   ./model.sh
   ```
7. Run the script to select and execute an LLM model and save the benchmarks
   ```
   ./run.sh
   ```
8. Run the other scripts benchmark other results. 
   ```
   ./run_all.sh
   ./t_run.sh
   ./prompt_run.sh
   ```




## Things to Do:
- [x] Create script to run a model and log the benchmarks
- [ ] Merge individual scripts to a single master script
- [ ] create supporting scripts for Windows OS (Latte Panda)
- [x] Create scripts for downloading the models and setting up the environment
- [x] Optimise the scripts with modular components
