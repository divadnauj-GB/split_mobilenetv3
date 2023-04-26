#!/bin/bash

START=1
END=15

source ~/miniconda3/bin/activate sc2-benchmark

PWD=`pwd`
Global_path="$PWD"

MODE=$1


if [ $MODE == "W" ]; then 

    for (( i=${START}; i<=${END}; i++ )); do
        python merge_reports_FI.py --path ${Global_path}/FSIMs/W_Results_cnf_5_lyr${i}/FSIM_logs/split5_faulty_weights_${i} &
    done
else

    python merge_reports_FI.py --path ${Global_path}/FSIMs/N_Results_cnf_5_lyr15/FSIM_logs/split5_faulty_neurons_15 &
    python merge_reports_FI.py --path ${Global_path}/FSIMs/N_Results_cnf_5_lyr_0-15/FSIM_logs/split5_faulty_neurons_0 &


fi