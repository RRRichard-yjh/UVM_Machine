
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
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')#json: test, seq
    parser.add_argument('-add_seq', default='./auto_add_seq/new_seq_name.txt', type=str, help='Path to new seq file')#add_seq
    parser.add_argument('-prompt', default='./auto_test/prompt_add_test.txt', type=str, help='Path to prompt add_test file')#prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]  
    module_name = module_info['moduleName']  # Module name
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_add_test: {module_name}")

    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)
    
    test_file = f"./{uvm_testbench}/{module_name}_test.sv"
    seq_file = f"./{uvm_testbench}/{module_name}_seq.sv"

    with open(test_file, 'r', encoding='utf-8') as testf:
        test_content = testf.read()
    with open(seq_file, 'r', encoding='utf-8') as seqf:
        seq_content = seqf.read()
    with open(args.add_seq, 'r', encoding='utf-8') as add_seqf:
        add_seq_content = add_seqf.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    prompt1 = (
        f'''{test_content}'''
        f'''{seq_content}'''
        f'''{add_seq_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_test/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:
        output_file_name = f"./auto_test/{module_name}_test.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])
	   
