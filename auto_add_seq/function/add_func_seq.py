
import os
import requests
import json
import re
import argparse

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
    parser = argparse.ArgumentParser(description='')

    # Load module information from JSON
    with open('module_info.json', 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]
    module_name = module_info['moduleName']
    paths = module_info['paths']

    # Extract and format paths
    dut_path = paths['dut'].format(moduleName=module_name)
    uvm_testbench_path = paths['uvm_testbench'].format(moduleName=module_name)

    
    parser.add_argument('-func', default=f'./auto_function/{module_name}_function.txt', type=str, help='Function file path')
    parser.add_argument('-dut_file', default=dut_path, type=str, help='dut file path')
    parser.add_argument('-tr_file', default=f'./{uvm_testbench_path}/{module_name}_seq_item.sv', type=str, help='Transaction file path')
    parser.add_argument('-seq_file', default=f'./{uvm_testbench_path}/{module_name}_seq.sv', type=str, help='Sequence file path')
    parser.add_argument('-input_file', default='./auto_add_seq/input_signal.txt', type=str, help='Path to input signal file')  # input_signal
    parser.add_argument('-cov_file', default='./auto_coverage/uncovered_bins.txt', type=str, help='Coverage file path')
    parser.add_argument('-funcov_file', default=f'./{uvm_testbench_path}/{module_name}_subscriber.sv', type=str, help='Functional coverage file path')
    parser.add_argument('-class_names', default='./auto_seq/seq_class_name.txt', type=str, help='Path to class name in old seq')  # class_names
    parser.add_argument('-prompt', default='./auto_add_seq/function/prompt_add_func_seq.txt', type=str, help='Prompt file path')

    args = parser.parse_args()

    # Read file contents
    with open(args.func, 'r', encoding='utf-8') as funcf:
        func_content = funcf.read()
    with open(args.dut_file, 'r', encoding='utf-8') as dutf:
        dut_content = dutf.read()
    with open(args.tr_file, 'r', encoding='utf-8') as trf:
        tr_content = trf.read()
    with open(args.seq_file, 'r', encoding='utf-8') as seqf:
        seq_content = seqf.read()
    with open(args.input_file, 'r', encoding='utf-8') as inputf:
        input_content = inputf.read()
    with open(args.cov_file, 'r', encoding='utf-8') as covf:
        cov_content = covf.read()
    with open(args.funcov_file, 'r', encoding='utf-8') as funcovf:
        funcov_content = funcovf.read()
    with open(args.class_names, 'r', encoding='utf-8') as namesf:
        class_names_content = namesf.read()
    with open(args.prompt, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    prompt1 = (
        f'''{func_content}'''
        f'''{dut_content}'''
        f'''{tr_content}'''
        f'''{seq_content}'''
        f'''{input_content}'''
        f'''{cov_content}'''
        f'''{funcov_content}'''
        f'''{class_names_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_add_seq/function/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(
        r'```systemverilog([\s\S]+?)```',
        answer1,
        re.IGNORECASE
    )
    if content:
        #with open(r"./auto_add_seq/function/gpt4o_add_func_seq.sv", "w", encoding='utf-8') as wf:
        #    wf.write(content[0])

        output_file_name = f"./auto_add_seq/function/{module_name}_add_func_seq.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])


