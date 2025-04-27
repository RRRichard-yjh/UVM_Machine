
import os
import json
import argparse
import requests
import re

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
    parser = argparse.ArgumentParser(description='Script to process JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')  # JSON: spec, dut
    parser.add_argument('-input_file', default='./auto_add_seq/input_signal.txt', type=str, help='Path to input signal file')  # input_signal
    parser.add_argument('-cov_file', default='./auto_coverage/uncovered_code/branch_coverage.txt', type=str, help='Path to coverage file')  # coverage
    parser.add_argument('-class_names', default='./auto_seq/seq_class_name.txt', type=str, help='Path to class name in old seq')  # class_names
    parser.add_argument('-prompt', default='./auto_add_seq/code/branch/prompt_add_branch_code_seq.txt', type=str, help='Path to prompt function file')  # prompt

    args = parser.parse_args()

    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]  
    module_name = module_info['moduleName']  
    paths = module_info['paths']  

    # Extract and format paths
    spec_path = paths['spec'].format(moduleName=module_name)
    dut_path = paths['dut'].format(moduleName=module_name)
    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)

    tr_file = f"./{uvm_testbench}/{module_name}_seq_item.sv"
    seq_file = f"./{uvm_testbench}/{module_name}_seq.sv"

    # Read file contents
    with open(spec_path, 'r', encoding='utf-8') as specf:
        spec_content = specf.read()
    with open(dut_path, 'r', encoding='utf-8') as dutf:
        dut_content = dutf.read()
    with open(tr_file, 'r', encoding='utf-8') as trf:
        tr_content = trf.read()
    with open(seq_file, 'r', encoding='utf-8') as seqf:
        seq_content = seqf.read()
    with open(args.input_file, 'r', encoding='utf-8') as inputf:
        input_content = inputf.read()
    with open(args.cov_file, 'r', encoding='utf-8') as covf:
        cov_content = covf.read()
    with open(args.class_names, 'r', encoding='utf-8') as namesf:
        class_names_content = namesf.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    # Combine prompts
    prompt1 = (
        f'''{spec_content}'''
        f'''{dut_content}'''
        f'''{tr_content}'''
        f'''{seq_content}'''
        f'''{input_content}'''
        f'''{cov_content}'''
        f'''{class_names_content}'''
        f'''{p_content}'''
    )

    # Combine prompts
    answer1 = get_request(prompt1)
    print(answer1)

    # Write the result to the specified output file
    with open(r"./auto_add_seq/code/branch/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:
        output_file_name = f"./auto_add_seq/code/branch/{module_name}_add_branch_code_seq.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])


