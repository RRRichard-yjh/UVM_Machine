

import re
import argparse
import os
import json

def generate_sequencer(module_name):
    sequencer_name = f"{module_name}_sequencer"
    return f"""
class {sequencer_name} extends uvm_sequencer #({module_name}_seq_item);
    `uvm_component_utils({sequencer_name})

    function new(string name = "{sequencer_name}", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
"""

def generate_sequencer_file(dut_path, module_name):
    try:
        output_file_name = f"./auto_sequencer/{module_name}_sequencer.sv"
        os.makedirs(os.path.dirname(output_file_name), exist_ok=True)
        with open(output_file_name, 'w', encoding='utf-8') as f:
            f.write(generate_sequencer(module_name))
        print(f"Generated successfully: {os.path.normpath(output_file_name)}")
    except Exception as e:
        print(f"Generation failed: {str(e)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Configure UVM interface files based on JSON files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='JSON configuration file path')
    args = parser.parse_args()

    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]
    module_name = module_info['moduleName']  
    
    dut_path = module_info['paths']['dut'].format(moduleName=module_name)

    generate_sequencer_file(dut_path, module_name)
