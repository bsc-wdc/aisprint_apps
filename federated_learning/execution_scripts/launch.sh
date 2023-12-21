#!/bin/bash

compss_clean_procs
NUM_RETRIES="3"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
base_app_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )

log_dir="/tmp/test/"
mkdir -p "${log_dir}"
output_log="${log_dir}test.outputlog"
error_log="${log_dir}test.errorlog"
touch "${output_log}"
touch "${error_log}"

echo "    Starting Agent1"
agent_log_dir="${log_dir}/agent1/"
agent_output_log="${log_dir}/agent1.outputlog"
agent_error_log="${log_dir}/agent1.errorlog"
compss_agent_start \
  --hostname="COMPSsWorker01" \
  --pythonpath=${base_app_dir} \
  --log_dir="${agent_log_dir}" \
  --rest_port="46101" \
  --comm_port="46102" \
  -t \
  -d \
  --project="${SCRIPT_DIR}/deployment/project_24.xml" \
  --resources="/opt/COMPSs/Runtime/configuration/xml/resources/examples/local/resources.xml" \
1>"${agent_output_log}" 2>"${agent_error_log}" &
PID=$!
PIDS="${PID}"

echo "    Starting Agent2"
agent_log_dir="${log_dir}/agent2/"
agent_output_log="${log_dir}/agent2.outputlog"
agent_error_log="${log_dir}/agent2.errorlog"
compss_agent_start \
  --hostname="COMPSsWorker02" \
  --pythonpath=${base_app_dir} \
  --log_dir="${agent_log_dir}" \
  --rest_port="46201" \
  --comm_port="46202" \
  -t \
  -d \
  --project="${SCRIPT_DIR}/deployment/project_48.xml" \
  --resources="/opt/COMPSs/Runtime/configuration/xml/resources/examples/local/resources.xml" \
1>"${agent_output_log}" 2>"${agent_error_log}" &
PID=$!
PIDS="${PIDS} ${PID}"

echo "    Starting Agent3"
agent_log_dir="${log_dir}/agent3/"
agent_output_log="${log_dir}/agent3.outputlog"
agent_error_log="${log_dir}/agent3.errorlog"
compss_agent_start \
  --hostname="COMPSsWorker03" \
  --pythonpath=${base_app_dir} \
  --log_dir="${agent_log_dir}" \
  --rest_port="46301" \
  --comm_port="46302" \
  -t \
  -d \
  --project="${SCRIPT_DIR}/deployment/project_48.xml" \
  --resources="/opt/COMPSs/Runtime/configuration/xml/resources/examples/local/resources.xml" \
1>"${agent_output_log}" 2>"${agent_error_log}" &
PID=$!
PIDS="${PIDS} ${PID}"

echo "    Starting Agent4"
agent_log_dir="${log_dir}/agent4/"
agent_output_log="${log_dir}/agent4.outputlog"
agent_error_log="${log_dir}/agent4.errorlog"
compss_agent_start \
  --hostname="COMPSsWorker04" \
  --pythonpath=${base_app_dir} \
  --log_dir="${agent_log_dir}" \
  --rest_port="46401" \
  --comm_port="46402" \
  -t \
  -d \
  --project="${SCRIPT_DIR}/deployment/project_48.xml" \
  --resources="/opt/COMPSs/Runtime/configuration/xml/resources/examples/local/resources.xml" \
1>"${agent_output_log}" 2>"${agent_error_log}" &
PID=$!
PIDS="${PIDS} ${PID}"

for device_idx in `seq 1 4`; do
  retries="${NUM_RETRIES}"
  curl -XGET "http://127.0.0.1:46101/COMPSs/test" 1>/dev/null 2>/dev/null
  exit_val=$?
  while [ ! "${exit_val}" == "0" ] && [ "${retries}" -gt "0" ]; do
    sleep 1
    retries=$((retries - 1 ))
    curl -XGET "http://127.0.0.1:46101/COMPSs/test" 1>/dev/null 2>/dev/null
    exit_val=$?
  done
  if [ ${exit_val} != 0 ]; then
    echo "    Agent${device_idx} could not be started"
    exit 1
  fi
  echo "    Agent${device_idx} started"
done

for device_idx in `seq 2 4`; do
compss_agent_add_resources \
  --agent_node="127.0.0.1" \
  --agent_port="46101" \
  --cpu=48 \
  COMPSsWorker0${device_idx} \
  Port=46${device_idx}02
done



echo "Resource summary"
  echo "Agent1"
  curl -XGET "http://127.0.0.1:46101/COMPSs/resources"
  echo ""


echo "Calling operation"
compss_agent_call_operation \
   --master_node="127.0.0.1" \
   --master_port="46101" \
   --lang=python \
   --stop \
   --forward_to="127.0.0.1:46201;127.0.0.1:46301;127.0.0.1:46401" \
   --method_name="main_program" \
   learning \
   "COMPSsWorker02@dataset.npy,COMPSsWorker02@dataset_y.npy,COMPSsWorker03@dataset.npy,COMPSsWorker03@dataset_y.npy,COMPSsWorker04@dataset.npy,COMPSsWorker04@dataset_y.npy" "testset.npy,testset_y.npy"
  
wait ${PIDS}