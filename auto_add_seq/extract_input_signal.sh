
#!/bin/bash


# Use Python to extract the moduleName and uvm_testbench from module_info.json
module_info=$(python3 -c "
import json
with open('./module_info.json', 'r') as f:
    data = json.load(f)
    module_name = data['modules'][0]['moduleName']
    uvm_testbench = data['modules'][0]['paths']['uvm_testbench']
    print(f'{module_name} {uvm_testbench}')
")

module_name=$(echo "$module_info" | awk '{print $1}')
uvm_testbench=$(echo "$module_info" | awk '{print $2}')

uvm_testbench=$(echo "$uvm_testbench" | sed "s/{moduleName}/$module_name/g")

# Set the input and output file paths
input_file="${uvm_testbench}/${module_name}_seq_item.sv"
output_file="./auto_add_seq/input_signal.txt"

# Clear the output file
> "$output_file"

declare -A defines
while IFS= read -r line; do
  if [[ "$line" =~ ^\`define[[:space:]]+([A-Za-z_][A-Za-z0-9_-]*)[[:space:]]+([0-9]+) ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    defines["$key"]="$value"
  fi
done < "$input_file"


while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*rand ]]; then
    for key in "${!defines[@]}"; do
      if [[ "$line" =~ \[.*\`$key([^]]*)\] ]]; then
        line=$(echo "$line" | sed -E "s/\[\`$key([^]]*)\]/\[${defines[$key]}\1\]/g")
      fi
    done
    echo "$line" >> "$output_file"
  fi
done < "$input_file"

echo "The extracted lines of code have been saved to $output_file"
