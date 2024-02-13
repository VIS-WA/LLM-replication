import matplotlib.pyplot as plt
import numpy as np
import os

# This is how the data is in a benchmark file
'''
      sample time =       7.13 ms /    16 runs   (    0.45 ms per token,  2245.30 tokens per second)
 prompt eval time =    1373.31 ms /    19 tokens (   72.28 ms per token,    13.84 tokens per second)
        eval time =    3264.10 ms /    15 runs   (  217.61 ms per token,     4.60 tokens per second)
       total time =    4652.41 ms /    34 tokens
Maximum memory used: 5206 MB
'''

# The folder structure is as follows:
#  - benchmarks/models_n/run_i.txt where model_n is the name of the model and run_i is the i-th run of the model.
# For a given model, plot the prompt eval time and the eval time for each run.
# The x-axis will be the run number, and the y-axis will be the time in ms.

# model = "llama-2-7b.Q4_K_M.gguf" # "phi-2.Q4_K_M.gguf" or "llama-2-7b.Q4_K_M.gguf"
# device = "OP" # "System" or "LP" or "OP"
# dir = "benchmarks/"+device+"/"+model+"/runs"
# output_dir = "plots/"+device+"/"


# ## Timings
# # All the folders present in the benchmarks folder are the models
# models = os.listdir(dir)
# # For each model, get the run files
# for model in models:
#     print("Plotting " + model)
#     # Get the files in the folder
#     files = os.listdir(dir+"/" + model)
#     # Get the number of runs
#     num_runs = len(files)
#     # Create the x-axis
#     x = np.arange(1, num_runs + 1)
#     # Create the y-axis
#     prompt_eval_times = []
#     eval_times = []
#     for file in files:
#         # Open the file
#         f = open(dir+"/" + model + "/" + file, "r")
#         # Read the lines
#         lines = f.readlines()
#         # Get the prompt eval time
#         # print(lines[1].split()[4])
#         prompt_eval_time = float(lines[1].split()[4])
#         # Get the eval time
#         # print(lines[2].split())
#         eval_time = float(lines[2].split()[3])
#         # Append to the arrays
#         prompt_eval_times.append(prompt_eval_time)
#         eval_times.append(eval_time)
#         # Close the file
#         f.close()
#     # Plot the prompt eval time on left y-axis and eval time on right y-axis
#     fig, ax1 = plt.subplots()
#     ax2 = ax1.twinx()
#     ax1.plot(x, prompt_eval_times, 'g-')
#     ax2.plot(x, eval_times, 'b-')
#     # Set the title
#     plt.title(model)
#     # Set the x-axis label
#     ax1.set_xlabel('Run')
#     # Set the y-axis label
#     ax1.set_ylabel('Prompt eval time (ms)', color='g')
#     ax2.set_ylabel('Eval time (ms)', color='b')
#     # Save the plot
#     plt.savefig(output_dir+"time-"+model+".png")
#     # Clear the plot
#     plt.clf()

    
# exit(0)
'''
#=======================================================================================================================
## Memory usage
# plot the memory usage for all models across all runs for a given device
# The folder structure is as follows:
#  - benchmarks/device/models_n/run_i.txt where model_n is the name of the model and run_i is the i-th run of the model.
# The x-axis will be the run, and the y-axis will be the memory usage in MB and plot all the models in the same plot

device = "System" # "System" or "LP" or "OP"
dir = "benchmarks/"+device+"/"
output_dir = "plots/"+device+"/"

n_runs = 5
# plot the memory usage for each model across all runs for a given device
# All the folders present in the benchmarks folder are the models
models = os.listdir(dir)
# Create the x-axis
x = np.arange(1, n_runs + 1)
# Create the y-axis
for model in models:
    print("Plotting " + model)
    # Get the files in the folder
    files = os.listdir(dir + model)
    # Create the y-axis
    memory_usage = []
    for file in files:
        # if a folder is present, skip it
        if os.path.isdir(dir + model + "/" + file):
            continue
        # Open the file
        f = open(dir + model + "/" + file, "r")
        # Read the lines
        lines = f.readlines()
        # Get the memory usage
        # print(lines[3].split())
        memory = float(lines[4].split()[3])
        # Append to the array
        memory_usage.append(memory)
        # Close the file
        f.close()
    # Plot the memory usage
    plt.plot(x, memory_usage, label=model)
# Set the title
plt.title("Memory usage on " + device)
# Set the x-axis label
plt.xlabel('Run')
# Set the y-axis label
plt.ylabel('Memory usage (MB)')
# Set the legend
plt.legend()
# Save the plot
plt.savefig(output_dir+"memory-"+device+".pdf")
# Clear the plot
plt.clf()




#=======================================================================================================================
## no of CPU vs time
model = "llama-2-7b.Q4_K_M.gguf" # "phi-2.Q4_K_M.gguf" or "llama-2-7b.Q4_K_M.gguf" or "mistral-7b-instruct-v0.2.Q4_K_M.gguf" or "tiiuae-falcon-7b-instruct-Q4_K_M.gguf"
device = "LP" # "System" or "LP" or "OP"
dir = "benchmarks/"+device+"/"+model+"/threads"
output_dir = "plots/"+device+"/"

# plot the eval time for each file which represents the number of CPU threads used starting with 1. The x-axis will be number of threads, and the y-axis will be the time in ms.
# The folder structure is as follows:
#  - benchmarks/phi-2.Q4_K_M.gguf/threads/i.txt where i is the i-th file with the i number of threads used.
# Get the files in the folder
files = os.listdir(dir)
# Get the number of threads
num_threads = len(files)
# Create the x-axis
x = np.arange(1, num_threads + 1)
# Create the y-axis
eval_times = []
for file in files:
    # Open the file
    f = open(dir + "/" + file, "r")
    # Read the lines
    lines = f.readlines()
    # Get the eval time
    # print(lines[2].split())
    eval_time = float(lines[2].split()[3])
    # Append to the array
    eval_times.append(eval_time)
    # Close the file
    f.close()
# Plot the eval time
    
plt.plot(x, eval_times)
# Set the title
plt.title("Model: "+model+"\nDevice: "+device)
# plot a dot at the number of threads for which the eval time is the least on the plot using argmin
min_index = np.argmin(eval_times)
min_threads = min_index + 1
min_time = eval_times[min_index]
plt.plot(min_threads, min_time, 'ro')
# Set the x-axis label
plt.xlabel("Number of threads")
# Set the y-axis label
plt.ylabel("Eval time (ms)")
# Save the plot
plt.savefig(output_dir+"threads-"+model+".png")
# Clear the plot
plt.clf()

'''

#=======================================================================================================================

## prompt size vs memory usage and eval time
model = "phi-2.Q4_K_M.gguf" # "phi-2.Q4_K_M.gguf" or "llama-2-7b.Q4_K_M.gguf" or "mistral-7b-instruct-v0.2.Q4_K_M.gguf" or "tiiuae-falcon-7b-instruct-Q4_K_M.gguf"
device = "System" # "System" or "LP" or "OP"
dir = "benchmarks/"+device+"/"+model+"/prompts"
output_dir = "plots/"+device+"/"

# plot the memory usage and eval time for each file which represents the prompt size. The x-axis will be the prompt size, and the y-axis will be the memory usage in MB and eval time in ms.
# The folder structure is as follows:
#  - benchmarks/phi-2.Q4_K_M.gguf/prompts/i.txt.  The length of ith line of prompt.txt in the parent directory is the prompt size for the ith file in the prompts folder.
# Get the files in the folder
files = os.listdir(dir)
# Get the prompt sizes from the prompt.txt file
f = open("prompt.txt", "r")
# Read the lines
lines = f.readlines()
# Get the prompt sizes
prompt_sizes = []
for line in lines:
    prompt_sizes.append(len(line))
# Close the file
f.close()
# Create the x-axis
x = np.array(prompt_sizes)
# Create the y-axis
memory_usage = []
eval_times = []
for file in files:
    # Open the file
    f = open(dir + "/" + file, "r")
    # Read the lines
    lines = f.readlines()
    # Get the memory usage
    # print(lines[3].split())
    memory = float(lines[4].split()[3])
    # Get the eval time
    # print(lines[2].split())
    eval_time = float(lines[2].split()[3])
    # Append to the array
    memory_usage.append(memory)
    eval_times.append(eval_time)
    # Close the file
    f.close()
# Plot the memory usage
fig, ax1 = plt.subplots()
ax2 = ax1.twinx()
ax1.plot(x, memory_usage, 'g-')
ax2.plot(x, eval_times, 'b-')
# Set the title
plt.title("Model: "+model+"\nDevice: "+device)
# Set the x-axis label
ax1.set_xlabel('Prompt size (characters)')
# Set the y-axis label
ax1.set_ylabel('Memory usage (MB)', color='g')
ax2.set_ylabel('Eval time (ms)', color='b')
# Save the plot
plt.savefig(output_dir+"prompt-"+model+".png")
# Clear the plot
plt.clf()

