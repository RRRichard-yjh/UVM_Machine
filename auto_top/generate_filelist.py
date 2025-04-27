
import json
import os
import re

# Define the template for the UVM test file
filelist_template = """+incdir+$UVM_HOME/src
$UVM_HOME/src/uvm_pkg.sv
../rtl/{module_name}.v
../testbench/{module_name}_if.sv
../testbench/{module_name}_seq_item.sv
../testbench/{module_name}_reference_model.sv
../testbench/{module_name}_subscriber.sv
../testbench/{module_name}_seq.sv
../testbench/{module_name}_sequencer.sv
../testbench/{module_name}_driver.sv
../testbench/{module_name}_monitor.sv
../testbench/{module_name}_agent.sv
../testbench/{module_name}_scoreboard.sv
../testbench/{module_name}_env.sv
../testbench/{module_name}_test.sv
../testbench/{module_name}_Top.sv

"""


def generate_filelist(module_name, filelist_description):
    
    file_name = f"{module_name}_list.f"
    file_path = os.path.join("./auto_top", file_name)  

    test_content = filelist_template.format(
        module_name=module_name,
        filelist_description=filelist_description,
    )
    
    with open(file_path, 'w') as file:
        file.write(test_content)
    
    print(f"Generated filelist: {file_path}")

def main():
    with open('./module_info.json', 'r') as file:
        data = json.load(file)
    
    module_name = data['modules'][0]['moduleName']
     
    generate_filelist(module_name, f"This is a description of {module_name}_list.")

# Run the main function
if __name__ == "__main__":
    main()
