#!/bin/bash

# Function to terminate the script and all child processes
terminate_script() {
    echo "Terminating..."
    # Send SIGINT signal to all child processes
    for pid in "${child_pids[@]}"; do
        kill -SIGINT "$pid"  # Send SIGINT signal to each child process
    done
    exit
}

trap 'terminate_script' INT

conda deactivate
source ~/miniconda3/bin/activate sc2-benchmark

PWD=`pwd`
echo ${PWD}
global_PWD="$PWD"
echo ${CUDA_VISIBLE_DEVICES}

target_config="$1"
channels="$2"

Sim_dir=$global_PWD
mkdir -p ${Sim_dir}

python ${global_PWD}/train.py\
    --checkpoint ${global_PWD}/split${target_config}\
    --data ${global_PWD}/data\
    --warmup\
    --lr 0.001\
    --epochs 200\
    --config ${Sim_dir}/configs/split${target_config}_ch${channels}.yaml