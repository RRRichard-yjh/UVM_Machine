
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
    print(f"\nExtracted module_name: {module_name}")

    spec_path = paths['spec'].format(moduleName=module_name)
    dut_path = paths['dut'].format(moduleName=module_name)
    uvm_testbench_path = paths['uvm_testbench'].format(moduleName=module_name)
    drv_path = os.path.join(uvm_testbench_path, f'{module_name}_driver.sv')
    if_path = os.path.join(uvm_testbench_path, f'{module_name}_if.sv')
    item_path = os.path.join(uvm_testbench_path, f'{module_name}_seq_item.sv')
    sqr_path = os.path.join(uvm_testbench_path, f'{module_name}_sequencer.sv')

    with open(spec_path, 'r') as file:
        spec_content = file.read()
    with open(dut_path, 'r') as file:
        dut_content = file.read()
    with open(drv_path, 'r') as file:
        drv_content = file.read()
    with open('./fix_component_code/check_errors.txt', 'r') as file:
        err_content = file.read()
    with open(if_path, 'r') as file:
        interface_content = file.read()
    with open(item_path, 'r') as file:
        seq_item_content = file.read()
    with open(sqr_path, 'r') as file:
        sequencer_content = file.read()

    if "Error-[MFNF]" in err_content:
        print("\n\033[1mStart correcting MFNF of driver...\033[0m")
        prompt1 = f"""
You are a professional digital circuit verification engineer, skilled in using UVM to build verification frameworks and writing verification components. Next, I will provide a DUT. Please help me write the driver component.
Please read the provided spec and DUT code first.
Spec:
{spec_content}
DUT code:
{dut_content}
requirements:
1. Components need to be registered in the factory mechanism of UVM.
2. The component name is {module_name}_driver.
3. Non blocking assignment is generally used instead of blocking assignment in Driver to simulate hardware behavior and avoid potential competition conditions.
"""
        answer1 = get_request(prompt1)
        with open(drv_path, 'w', encoding='utf-8') as file:
            file.write(answer1)
        with open(drv_path, 'r') as file:
            answer1_content = file.read()

        print("\033[1m...\033[0m")
        prompt2 = f"""
The following is a preliminary driver component generated based on spec and DUT code:
{answer1_content}
The following are the corresponding interface, sequencer and sequence items in the verification environment.
Interface:
{interface_content}
Sequencer:
{sequencer_content}
Sequence item:
{seq_item_content}
Please modify the driver component based on the supplementary information, while meeting the following requirements:
1. Driver does not directly operate the output signal of the DUT.
2. The clock signal or reset signal can be transmitted from the interface through a virtual interface. If these two signals are not present in the interface, do not create them yourself.
3. SystemVerilog does not support the direct use of + concatenation strings. If necessary, the $formatf or $psprintf functions can be used. Variable declarations must be located at the beginning of the begin end block or task/function.
4. Do not use signals and variables that are not declared in *_seq_item.sv within the task.
5. Do not wait for the clock edge inside the transaction.
6. {module_name}_seq_item.sv has already defined transactions and related constraints. Do not use statements like include *_transactions.sv.
7. Create corresponding item objects in the build phase.
8. All input signals in DUT need to be driven by the driver, unless they are not declared in *_seq_item.sv.
9. Wait for the clock edge before get_next_item. Do not wait for the acknowledge signal.
10. Just generate code, no need for explanation.
"""
        answer2 = get_request(prompt2)
        lines = answer2.splitlines()
        processed_content = "\n".join(lines[1:-1])
    else:
        print("\n\033[1mStart correcting driver...\033[0m")
        prompt3 = f"""
You are a professional digital circuit verification engineer, skilled in using UVM to build verification frameworks and writing verification components. You need to modify the following driver components with errors.
Driver component:
{drv_content}
The following are the error messages generated when running the simulation.
error message:
{err_content}
Be sure to confirm that the class and component name are {module_name}_driver firstly.
Just generate code, no need for explanation.
"""
        answer3 = get_request(prompt3)
        lines = answer3.splitlines()
        processed_content = "\n".join(lines[1:-1])

    with open(drv_path, 'w', encoding='utf-8') as file:
        file.write(processed_content)
		
    print("\n\033[1mDriver has been updated.\033[0m")
