

import os
import json
import argparse
import requests
import re

# Set environment variables
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
    # Use argparse to get the JSON configuration file path
    parser = argparse.ArgumentParser(description='Script to process JSON configuration and other related files') 
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')#json
    parser.add_argument('-prompt', default='./auto_seq_item/prompt_tr.txt', type=str, help='Path to prompt function file')#prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0] 
    module_name = module_info['moduleName']  # Module name
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_seq_item: {module_name}")

    # Format paths with moduleName
    spec_path = paths['spec'].format(moduleName=module_name)
    uvm_testbench_path = paths['uvm_testbench'].format(moduleName=module_name)
    func_file = f"./auto_function/{module_name}_function.txt"
    interface_file = f"./auto_interface/{module_name}_if.sv"

    # Read file contents
    with open(spec_path, 'r', encoding='utf-8') as specf:
        spec_content = specf.read()
    with open(func_file, 'r', encoding='utf-8') as funcf:
        func_content = funcf.read()
    with open(interface_file, 'r', encoding='utf-8') as interfacef:
        interface_content = interfacef.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    # Concatenate prompt
    prompt1 = (
        f'''{spec_content}'''
        f'''{func_content}'''
        f'''{interface_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_seq_item/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:

        output_file_name = f"./auto_seq_item/{module_name}_seq_item.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])

