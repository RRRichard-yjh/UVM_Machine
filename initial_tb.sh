
#!/bin/bash


SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR" || exit 1

rm -rf urgReport simulation_success.txt 
rm -rf ./auto_coverage/uncovered_code ./auto_coverage/uncovered_bins.txt ./auto_coverage/extracted_coverage_data.txt 
rm ./auto_seq/seq_class_name.txt 
rm ./auto_add_seq/new_seq_name.txt ./auto_add_seq/input_signal.txt 
rm ./fix_component_code/check_errors.txt


# Step 1: Extract module name and paths from module_info.json
module_name=$(python3 -c "
import json
with open('./module_info.json') as f:
    data = json.load(f)
print(data['modules'][0]['moduleName'])
")

uvm_testbench=$(python3 -c "
import json
with open('./module_info.json') as f:
    data = json.load(f)
module_name = data['modules'][0]['moduleName']
uvm_testbench = data['modules'][0]['paths']['uvm_testbench'].format(moduleName=module_name)
print(uvm_testbench)
")

sim_path=$(python3 -c "
import json
with open('./module_info.json') as f:
    data = json.load(f)
module = data['modules'][0]
module_name = module['moduleName']
paths = module['paths']
sim_path = paths['sim'].format(moduleName=module_name)
print(sim_path)
")


# Step 2: Run initial Python scripts to generate files
python3 ./auto_function/auto_function.py
python3 ./auto_testcase/auto_testcase.py
python3 ./auto_interface/auto_interface.py
python3 ./auto_seq_item/auto_seq_item.py
python3 ./auto_sequencer/auto_sequencer.py
python3 ./auto_driver/auto_driver.py
python3 ./auto_monitor/auto_monitor.py
python3 ./auto_seq/auto_seq.py
python3 ./auto_agent/auto_agent.py
python3 ./auto_scb/auto_scb.py
python3 ./auto_env/auto_env.py
python3 ./auto_test/generate_uvm_test.py
python3 ./auto_top/auto_top.py
python3 ./auto_top/generate_filelist.py


# Step 3: Move generated files to simulation path
mv "./auto_interface/${module_name}_if.sv" "$uvm_testbench"
mv "./auto_seq_item/${module_name}_seq_item.sv" "$uvm_testbench"
mv "./auto_sequencer/${module_name}_sequencer.sv" "$uvm_testbench"
mv "./auto_driver/${module_name}_driver.sv" "$uvm_testbench"
mv "./auto_monitor/${module_name}_monitor.sv" "$uvm_testbench"
mv "./auto_seq/${module_name}_seq.sv" "$uvm_testbench"
mv "./auto_agent/${module_name}_agent.sv" "$uvm_testbench"
mv "./auto_scb/${module_name}_scoreboard.sv" "$uvm_testbench"
mv "./auto_env/${module_name}_env.sv" "$uvm_testbench"
mv "./auto_test/${module_name}_test.sv" "$uvm_testbench"
mv "./auto_top/${module_name}_Top.sv" "$uvm_testbench"
mv "./auto_top/${module_name}_list.f" "$uvm_testbench"


#rm "./auto_function/${module_name}_function.txt"
rm "./auto_testcase/${module_name}_testcase.txt"
rm "./auto_scb/${module_name}_scb_example.sv"

# Function to handle errors and generate new sequences
handle_errors() {

	local final_check=${1:-false}
	
	cd "$SCRIPT_DIR" || exit 1

	compile_log="${sim_path}/compile.log"
    elaborate_log="${sim_path}/elaborate.log"
    simv_log="${sim_path}/simv.log"

    # Check compile.log for errors
    if grep -q "Error" "$compile_log"; then
		
		if [ "$final_check" = false ]; then
		    ./fix_component_code/extract_errors.sh "$compile_log" "./fix_component_code/check_errors.txt"
            python3 ./fix_component_code/process_errors.py
            echo "Compilation error detected."

		else
            echo "Compilation error not detected."

		fi

        return 1
    fi

    # Check elaborate.log for errors
    if grep -q "Error" "$elaborate_log"; then
		
		if [ "$final_check" = false ]; then
		    ./fix_component_code/extract_errors.sh "$elaborate_log" "./fix_component_code/check_errors.txt"
            python3 ./fix_component_code/process_errors.py
            echo "Executable generation error detected."
		else
            echo "Executable generation error not detected."

		fi

        return 1
    fi

    # Check simulation log (simv.log) for errors
    uvm_error_count=$(grep -c "UVM_ERROR" "$simv_log")
    uvm_fatal_count=$(grep -c "UVM_FATAL" "$simv_log")
    general_error_count=$(grep -c "Error" "$simv_log")

    if [ "$uvm_error_count" -le 1 ] && [ "$uvm_fatal_count" -le 1 ] && [ "$general_error_count" -eq 0 ]; then
        echo "Simulation passed."
        return 0
    else
        if [ "$general_error_count" -gt 0 ]; then
			
			if [ "$final_check" = false ]; then
			    ./fix_component_code/extract_errors.sh "$simv_log" "./fix_component_code/check_errors.txt"
                python3 ./fix_component_code/process_errors.py
                echo "General simulation error detected."
			else
                echo "General simulation error not detected."
			fi
            return 1
        else
            echo "UVM_ERROR or UVM_FATAL count exceeded limits. Stopping the flow."
            exit 1
        fi
    fi

}

# Step 4: Simulation loop with retry limit
cd "$sim_path" || exit

make clean
make run

max_retries=2
retry_count=0

while true; do
    if handle_errors; then
        break
    else
        retry_count=$((retry_count + 1))
        echo "Retry attempt: $retry_count"
        
		rm ./fix_component_code/check_errors.txt
        
		if [ "$retry_count" -ge "$max_retries" ]; then
			 
			cd "$sim_path"
            make clean
            make run

            if handle_errors true; then
                break
            else
                echo "Maximum retry limit ($max_retries) reached. Stopping the flow for manual intervention."
                echo "Please check the logs and correct the errors manually."
                exit 1
            fi
        else
            cd "$sim_path" || exit
            make clean
            make run
        fi
    fi
done

echo "Simulation passed successfully." > simulation_success.txt


# ----------------------
# Initial Coverage Collection
# ----------------------

echo "Starting initial coverage collection..."

# Collect coverage
urg -dir "$sim_path/coverage/cov.vdb"

# Analyze code/function coverage
python3 ./auto_coverage/judge_html_code.py
python3 ./auto_coverage/judge_html_function.py
python3 ./auto_coverage/py_hir.py
