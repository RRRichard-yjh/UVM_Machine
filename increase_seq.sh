
#!/bin/bash




SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR" || exit 1


# Extract module information
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

# ----------------------
# Keep the original incentive file
# ----------------------

# Copy sequence file
src_seq="${uvm_testbench}/${module_name}_seq.sv"
dest_seq="${uvm_testbench}/${module_name}_init_seq.sv"

if [[ ! -f "$dest_seq" ]]; then
    cp "$src_seq" "$dest_seq"
fi

# Copy test file
src_test="${uvm_testbench}/${module_name}_test.sv"
dest_test="${uvm_testbench}/${module_name}_init_test.sv"

if [[ ! -f "$dest_test" ]]; then
    cp "$src_test" "$dest_test"
fi

# ----------------------
# Coverage Analysis
# ----------------------

echo "Starting coverage analysis..."

./auto_add_seq/extract_input_signal.sh   #find tr signal
python3 ./auto_seq/extract_seq_class_names.py

# Analyze initial code coverage
while IFS= read -r line; do
    dut_score=$(echo "$line" | grep -oP '(?<=SCORE:)\d+\.\d+')
    if (( $(echo "$dut_score < 95" | bc -l) )); then
        echo "Initial code coverage is below 95%."
		bash ./auto_coverage/auto_code_coverage.sh
        break
    fi
done < ./auto_coverage/extracted_coverage_data.txt

# Analyze initial functional coverage
python3 ./auto_coverage/judge_html_function.py
bash ./auto_coverage/auto_function_coverage.sh



echo "Generating supplementary stimulus and new test cases..."
python3 ./auto_add_seq/supplementary_stimulus_handler.py
python3 ./auto_test/auto_add_test_old.py

#rm ./auto_seq/seq_class_name.txt

mv "./auto_test/${module_name}_test.sv" "$uvm_testbench"
echo "Initial preparation complete. Entering simulation."

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
            
			#rm -f "${uvm_testbench}/${module_name}_seq.sv"
            #rm -f "${uvm_testbench}/${module_name}_test.sv"
    
            mv "${uvm_testbench}/${module_name}_seq.sv" "${uvm_testbench}/${module_name}_incr_seq.sv"
            mv "${uvm_testbench}/${module_name}_test.sv" "${uvm_testbench}/${module_name}_incr_test.sv"
            
			mv "${uvm_testbench}/${module_name}_init_seq.sv" "${uvm_testbench}/${module_name}_seq.sv"
            mv "${uvm_testbench}/${module_name}_init_test.sv" "${uvm_testbench}/${module_name}_test.sv"

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
			
			#rm -f "${uvm_testbench}/${module_name}_seq.sv"
            #rm -f "${uvm_testbench}/${module_name}_test.sv"

			mv "${uvm_testbench}/${module_name}_seq.sv" "${uvm_testbench}/${module_name}_incr_seq.sv"
            mv "${uvm_testbench}/${module_name}_test.sv" "${uvm_testbench}/${module_name}_incr_test.sv"

    
            mv "${uvm_testbench}/${module_name}_init_seq.sv" "${uvm_testbench}/${module_name}_seq.sv"
            mv "${uvm_testbench}/${module_name}_init_test.sv" "${uvm_testbench}/${module_name}_test.sv"


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
				
				#rm -f "${uvm_testbench}/${module_name}_seq.sv"
                #rm -f "${uvm_testbench}/${module_name}_test.sv"

				mv "${uvm_testbench}/${module_name}_seq.sv" "${uvm_testbench}/${module_name}_incr_seq.sv"
                mv "${uvm_testbench}/${module_name}_test.sv" "${uvm_testbench}/${module_name}_incr_test.sv"

    
                mv "${uvm_testbench}/${module_name}_init_seq.sv" "${uvm_testbench}/${module_name}_seq.sv"
                mv "${uvm_testbench}/${module_name}_init_test.sv" "${uvm_testbench}/${module_name}_test.sv"

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


echo "Auto_add_seq script completed successfully."

# ----------------------
#Coverage Collection
# ----------------------

echo "Starting coverage collection..."

# Collect coverage
urg -dir "$sim_path/coverage/cov.vdb"

# Analyze coverage
python3 ./auto_coverage/judge_html_code.py
python3 ./auto_coverage/judge_html_function.py
python3 ./auto_coverage/py_hir.py
