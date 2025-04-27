
import re
import json
import subprocess


# Get module name from module_info.json
def get_module_name(json_path, file_name):
    with open(json_path, 'r') as file:
        data = json.load(file)
    for module in data['modules']:
        if module['moduleName'] in file_name:
            return module['moduleName']
    return None


# Extract information from check_errors.txt
def extract_error_info(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    match = re.search(r'["]?\.\./testbench/([a-zA-Z0-9_]+\.sv)["]?,\s*(\d+)', content)
    if match:
        return [(match.group(1), match.group(2))] 
    return []  


# Run the appropriate script
def run_script(file_name, module_name):
    if '_seq_item.sv' in file_name:
        script_name = './auto_seq_item/check_seq_item.py'
    elif '_seq.sv' in file_name:
        script_name = './auto_seq/check_seq.py'
    elif '_driver.sv' in file_name:
        script_name = './auto_driver/fix_driver.py'
    elif '_monitor.sv' in file_name:
        script_name = './auto_monitor/fix_monitor.py'
    elif '_test.sv' in file_name:
        script_name = './auto_test/check_test.py'
    else:
        return

    print(f"Error found in file: {file_name}")
    print(f"Running script: {script_name}")
    
    subprocess.run(['python3', script_name])


def main():
    error_info = extract_error_info('./fix_component_code/check_errors.txt')
    if error_info:  
        file_name, line_number = error_info[0]  
        print(f"Processing file: {file_name}, line: {line_number}")  
        module_name = get_module_name('./module_info.json', file_name)
        if module_name:
            run_script(file_name, module_name)
    else:
        print("No error information extracted.")  


if __name__ == '__main__':
    main()
