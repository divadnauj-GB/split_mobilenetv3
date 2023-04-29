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

PWD=`pwd`
echo ${PWD}
global_PWD="$PWD"
echo ${CUDA_VISIBLE_DEVICES}

target_config="$1"
channels="$2"
target_layer="$3"
GPUID="$4"
MODE="$5"

Sim_dir=${global_PWD}/FSIMs/${MODE}_Results_split${target_config}_ch${channels}_lyr${target_layer}
mkdir -p ${Sim_dir}

cp ${global_PWD}/configs/split${target_config}_ch${channels}.yaml ${Sim_dir}
cp ${global_PWD}/configs/split${target_config}_fault.yaml ${Sim_dir}

if [ ${MODE} == "N" ]; then
    sed -i "s/layers: \[.*\]/layers: \[$target_layer\]/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/trials: [0-9.]\+/trials: 5/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/size_tail_y: [0-9.]\+/size_tail_y: 32/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/size_tail_x: [0-9.]\+/size_tail_x: 32/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/block_fault_rate_delta: [0-9.]\+/block_fault_rate_delta: 0.2/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/block_fault_rate_steps: [0-9.]\+/block_fault_rate_steps: 5/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/neuron_fault_rate_delta: [0-9.]\+/neuron_fault_rate_delta: 0.1/" ${Sim_dir}/split${target_config}_fault.yaml
    sed -i "s/neuron_fault_rate_steps: [0-9.]\+/neuron_fault_rate_steps: 5/" ${Sim_dir}/split${target_config}_fault.yaml
    
    cd ${Sim_dir}
    CUDA_VISIBLE_DEVICES=$GPUID python ${global_PWD}/Inference_FI_Neuron.py\
    --checkpoint ${global_PWD}/split${target_config}\
    --data ${global_PWD}/data\
    --warmup\
    --config ${Sim_dir}/split${target_config}_ch${channels}.yaml\
    --resume ${global_PWD}/split${target_config}/split${target_config}_ch${channels}.pth.tar\
    --fsim_config ${Sim_dir}/split${target_config}_faulty.yaml > ${Sim_dir}/stdout.log 2> ${Sim_dir}/stderr.log
    child_pids+=($!)

else

    sed -i "s/layer: \[.*\]/layer: \[$target_layer\]/" ${Sim_dir}/split${target_config}_fault.yaml
    cd ${Sim_dir}
    CUDA_VISIBLE_DEVICES=$GPUID python ${global_PWD}/Inference_FI_weights.py\
    --checkpoint ${global_PWD}/split${target_config}\
    --data ${global_PWD}/data\
    --warmup\
    --config ${Sim_dir}/split${target_config}_ch${channels}.yaml\
    --resume ${global_PWD}/split${target_config}/split${target_config}_ch${channels}.pth.tar\
    --fsim_config ${Sim_dir}/split${target_config}_fault.yaml > ${Sim_dir}/stdout.log 2> ${Sim_dir}/stderr.log
    child_pids+=($!)
fi
echo "${child_pids[@]}"
