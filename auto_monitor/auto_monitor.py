
import os
import json
import argparse
import requests

os.environ["OPENAI_API_BASE"] = ""
os.environ["OPENAI_API_KEY"] = ""

model = "deepseek-v3-241226"

def get_request(prompt, temperature=0.2, max_new_tokens=4096, model=model):
    url = ''
    query = {
        "model": model,
        "prompt": prompt,
        "max_new_tokens": max_new_tokens,
        "temperature": temperature
    }

    request = requests.post(url, json=query)
    if request.json()["code"] == 200:
        return request.json()['data']
    else:
        return request

if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(description='Script for handling JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')
    args = parser.parse_args()

    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)
    
    module_info = config['modules'][0]
    module_name = module_info['moduleName']
    paths = module_info['paths']
    print(f"Extracted module_name in auto_monitor: {module_name}")

    spec_path = paths['spec'].format(moduleName=module_name)
    dut_path = paths['dut'].format(moduleName=module_name)

    with open(spec_path, 'r') as file:
        spec_content = file.read()
    with open(f'./auto_interface/{module_name}_if.sv', 'r') as file:
        interface_content = file.read()
    with open(f'./auto_seq_item/{module_name}_seq_item.sv', 'r') as file:
        seq_item_content = file.read()
    with open(f'./auto_monitor/monitor_framework.sv', 'r') as file:
        monitor_framework = file.read()
    
    prompt1 = f"""
You are a professional digital circuit verification engineer, skilled in using UVM to build verification frameworks and writing verification components. Next, I will provide a DUT. Please help me write the monitor component.
Please read the provided spec first.
Spec:
{spec_content}
requirements:
1. Components need to be registered in the factory mechanism of UVM.
2. The component name is {module_name}_monitor.
3. SystemVerilog does not support the direct use of + concatenation strings. If necessary, the $formatf or $psprintf functions can be used.
4. According to the design specifications, determine the conditions under which data needs to be collected.
"""
    print("\nStart generating monitor...")
    answer1 = get_request(prompt1)
   
    output_file_name = f"./auto_monitor/{module_name}_monitor.sv"
    with open(output_file_name, 'w', encoding='utf-8') as output_file:
        output_file.write(answer1)
    with open(output_file_name, 'r') as file:
        answer1_content = file.read()

    prompt2 = f"""
The following is a preliminary monitor component generated based on spec:
{answer1_content}
The following are the corresponding interfaces and sequence items in the verification environment.
Interface:
{interface_content}
Sequence item:
{seq_item_content}
Please regenerate the monitor component based on the supplementary information, fill in the following framework template, and meet the following requirements.
framework template:
{monitor_framework}
requirements:
1. {module_name}_seq_item.sv has already defined transactions and related constraints. Do not use statements like include *_transactions.sv.
2. The clock signal or reset signal can be transmitted from the interface through a virtual interface. If these two signals are not present in the interface, do not create them yourself.
3. If the output signal has the following characteristics, use uvm_event (such as a flag signal indicating the end of the data frame, a flag signal indicating output data ready), create it in the format of "uvm_event_pool:: get_global" and when the output signal is detected to be high, trigger the corresponding uvm_event, otherwise do not use it
4. Collect all signal and variable information declared in *_seq_item.sv, including clock and reset signals, and do not use undeclared signals and variables.
5. Do not add unnecessary delays or wait for unnecessary clock edges. Wait for the clock edge before get_next_item.
6. Obtain virtual interface using uvm_config_db in the build phase.
7. Non blocking assignment is generally used instead of blocking assignment in Monitor to simulate hardware behavior and avoid potential competition conditions.
8. Do not use if statements to collect data only after judging certain input or output signals, as this may cause the data entering the reference model to differ from that of the DUT.
9. Just generate code, no need for explanation.
"""

    print("\nStart improving monitor...")
    answer2 = get_request(prompt2)

	#delete ```
    lines = answer2.splitlines()
    processed_content = "\n".join(lines[1:-1])
    with open(output_file_name, 'w', encoding='utf-8') as output_file:
	    output_file.write(processed_content)
    #print(processed_content)
	
    print("\nFinished.")
