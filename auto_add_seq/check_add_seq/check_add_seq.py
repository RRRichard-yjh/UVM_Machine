
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
    parser.add_argument('-error_file', default='./auto_add_seq/check_add_seq/check_add_seq.txt', type=str, help='Path to error file')#error_file
    parser.add_argument('-prompt', default='./auto_add_seq/check_add_seq/prompt_check_add_seq.txt', type=str, help='Path to prompt function file')#prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]  
    module_name = module_info['moduleName']  
    paths = module_info['paths']  

    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)

    seq_file = f"./{uvm_testbench}/{module_name}_seq.sv"
    seq_item_file = f"./{uvm_testbench}/{module_name}_seq_item.sv"

    with open(seq_file, 'r', encoding='utf-8') as seqf:
        seq_content = seqf.read()
    with open(seq_item_file, 'r', encoding='utf-8') as trf:
        tr_content = trf.read()
    with open(args.error_file, 'r', encoding='utf-8') as errorf:
        error_content = errorf.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    prompt1 = (
        f'''{seq_content}'''
        f'''{tr_content}'''
        f'''{error_content}'''
        f'''{p_content}'''
    )


    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_add_seq/check_add_seq/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    corrected_file_marker = f"### Corrected Code"
    if corrected_file_marker in answer1:
        marker_index = answer1.index(corrected_file_marker)
        content_after_marker = answer1[marker_index + len(corrected_file_marker):]

        content = re.findall(
            r'```systemverilog([\s\S]+?)```',
            content_after_marker,
            re.IGNORECASE
        )

        if content:
            output_file_name = f"./auto_add_seq/check_add_seq/{module_name}_seq.sv"
            with open(output_file_name, 'w+', encoding='utf-8') as output_file:
                output_file.write(content[0])
   	   
