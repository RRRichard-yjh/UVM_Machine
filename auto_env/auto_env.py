
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

def check_ref_file_has_analysis_port(ref_content):
    """Check if reference model file contains uvm_analysis_port"""
    patterns = [
        r'uvm_analysis_port\s*#',
        r'uvm_analysis_imp\s*#',
        r'uvm_analysis_export\s*#'
    ]
    
    for pattern in patterns:
        if re.search(pattern, ref_content):
            return True
    return False



def main():
    # Use argparse to get the JSON configuration file path
    parser = argparse.ArgumentParser(description='Script to process JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')#json
    parser.add_argument('-prompt1', default='./auto_env/prompt_env_1.txt', type=str, help='Path to type 1 prompt env file')#prompt
    parser.add_argument('-prompt2', default='./auto_env/prompt_env_2.txt', type=str, help='Path to type 2 prompt env file')#prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]  
    module_name = module_info['moduleName']  # Module name
    
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_env: {module_name}")

    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)

    agent_file = f"./auto_agent/{module_name}_agent.sv"
    scb_file = f"./auto_scb/{module_name}_scoreboard.sv"
    ref_file = f"{uvm_testbench}/{module_name}_reference_model.sv"
    cov_file = f"{uvm_testbench}/{module_name}_subscriber.sv"
    intf_file = f"./auto_interface/{module_name}_if.sv"


    with open(ref_file, 'r', encoding='utf-8') as reff:
        ref_content = reff.read()
    
    # Choose template based on reference model content
    use_type2 = check_ref_file_has_analysis_port(ref_content)

    with open(agent_file, 'r', encoding='utf-8') as agentf:
        agent_content = agentf.read()
    with open(scb_file, 'r', encoding='utf-8') as scbf:
        scb_content = scbf.read()
    with open(cov_file, 'r', encoding='utf-8') as covf:
        cov_content = covf.read()
    with open(intf_file, 'r', encoding='utf-8') as intff:
        intf_content = intff.read()

    prompt_file = args.prompt2 if use_type2 else args.prompt1
    with open(prompt_file, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()


    prompt1 = (
        f'''{agent_content}'''
        f'''{scb_content}'''
        f'''{ref_content}'''
        f'''{cov_content}'''
        f'''{intf_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_env/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:
        output_file_name = f"./auto_env/{module_name}_env.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])

if __name__ == '__main__':
    main()   
