
import os
import json
import logging
import argparse
import re
import requests


os.environ["OPENAI_API_BASE"] = ""
os.environ["OPENAI_API_KEY"] = ""



model = "deepseek-v3-241226"


def get_request(prompt,temperature=0.2,max_new_tokens = 4096,model=model):
    url = ''
    query = {
        "model": model,
        "prompt":prompt,
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
    parser.add_argument('-prompt', default='./auto_agent/prompt_agent.txt', type=str, help='Path to prompt add_agent file')#prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]  
    module_name = module_info['moduleName']  # Module name
    
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_agent: {module_name}")

    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)

    driver_file = f"./auto_driver/{module_name}_driver.sv"
    monitor_file = f"./auto_monitor/{module_name}_monitor.sv"
    seqr_file = f"./auto_sequencer/{module_name}_sequencer.sv"
    intf_file = f"./auto_interface/{module_name}_if.sv"

    with open(driver_file, 'r', encoding='utf-8') as driverf:
        driver_content = driverf.read()
    with open(monitor_file, 'r', encoding='utf-8') as monitorf:
        monitor_content = monitorf.read()
    with open(seqr_file, 'r', encoding='utf-8') as seqrf:
        seqr_content = seqrf.read()
    with open(intf_file, 'r', encoding='utf-8') as intff:
        intf_content = intff.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    prompt1 = (
        f'''{driver_content}'''
        f'''{monitor_content}'''
        f'''{seqr_content}'''
        f'''{intf_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_agent/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:
        output_file_name = f"./auto_agent/{module_name}_agent.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])
	   
