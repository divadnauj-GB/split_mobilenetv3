#!/bin/bash

START=14
END=15

# Trap SIGINT signal (Ctrl+C)
trap 'terminate_script' INT

# Function to terminate the script and all child processes
terminate_script() {
    echo "Terminating..."
    # Send SIGINT signal to all child processes
    for pid in "${child_pids[@]}"; do
        kill -SIGKILL "$pid"  # Send SIGINT signal to each child process
    done
    exit
}

child_pids=()
for (( i=${START}; i<=${END}; i++ )); do
   bash ./Run_inference_FI.sh 5 ${i} 0 W &
   child_pids+=($!)
done

# Continue with the next line of code after all child processes have completed
echo "All commands have completed."