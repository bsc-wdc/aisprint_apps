#!/bin/bash

module load dislib/master
module load python/3.7.4
module unload COMPSs/2.10
module load COMPSs/Trunk
export ComputingUnits=4


# Define script constants
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATASET=/gpfs/scratch/bsc19/bsc19756/Federated_learning


# Create output directory
output_dir="${SCRIPT_DIR}/output"
mkdir -p "${output_dir}"

echo "Enqueueing a Randomforest training with Federated learning"

    # Create output directory
  output_dir="${SCRIPT_DIR}/output"
  mkdir -p "${output_dir}"

  # Run job
  enqueue_compss --qos=debug \
    --sc_cfg="mn.cfg" \
    \
    --num_nodes="4" \
    --exec_time="120" \
    -t \
    --log_level=off \
    \
    --cpus_per_node=48 \
    --worker_in_master_cpus=24 \
    \
    --master_working_dir="${output_dir}/" \
    --worker_working_dir="${output_dir}/" \
    --base_log_dir="${output_dir}" \
    --log_dir="${output_dir}" \
    --pythonpath="${SCRIPT_DIR}/application" \
    \
    --jvm_workers_opts="-Dcompss.worker.removeWD=false" \
    --agents=tree \
    \
    --method_name="main_program" \
    --lang="python" \
    "learning" "${DATASET}/first_dataset.npy,${DATASET}/first_dataset_y.npy,${DATASET}/second_dataset.npy,${DATASET}/second_dataset_y.npy,${DATASET}/third_dataset.npy,${DATASET}/third_dataset_y.npy" "${DATASET}/x_test.npy,${DATASET}/y_test.npy" 

