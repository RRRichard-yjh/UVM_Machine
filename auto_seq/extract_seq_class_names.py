

import json
import re
import os

def replace_placeholders(path, module_name):
    """
    Replace placeholders like {moduleName} in the path with the actual module name.
    """
    return path.replace("{moduleName}", module_name)

# Define the path to the module_info.json file
module_info_path = "./module_info.json"

if not os.path.exists(module_info_path):
    print(f"Error: {module_info_path} not found!")
    exit(1)

with open(module_info_path, "r") as f:
    module_info = json.load(f)

module_name = module_info["modules"][0]["moduleName"]
uvm_testbench = module_info["modules"][0]["paths"]["uvm_testbench"]

uvm_testbench = replace_placeholders(uvm_testbench, module_name)

if not module_name or not uvm_testbench:
    print("Error: Failed to extract module_name or uvm_testbench from module_info.json!")
    exit(1)

seq_file = os.path.join(uvm_testbench, f"{module_name}_seq.sv")

if not os.path.exists(seq_file):
    print(f"Error: {seq_file} not found!")
    exit(1)

output_file = "./auto_seq/seq_class_name.txt"

os.makedirs(os.path.dirname(output_file), exist_ok=True)

class_names = []
with open(seq_file, "r") as f:
    content = f.readlines()
    for line in content:
        match = re.match(r"\s*class\s+(\w+)\s+extends", line)
        if match:
            class_names.append(match.group(1))

if not class_names:
    print(f"Error: No valid class names found in {seq_file}.")
    exit(1)

with open(output_file, "w") as f:
    for name in class_names:
        f.write(f"{name}\n")

print(f"Class names extracted successfully and saved to {output_file}.")


