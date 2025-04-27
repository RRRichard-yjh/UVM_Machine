
import os
import json
import argparse
import requests

os.environ["OPENAI_API_BASE"] = ""
os.environ["OPENAI_API_KEY"] = ""


model = "deepseek-v3-241226"


def get_request(prompt, temperature=0.2, max_new_tokens=4096*2, model=model):
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
    parser = argparse.ArgumentParser(description='Script for handling JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file') #json
    parser.add_argument('-func', default='./auto_function/{module_name}_function.txt', type=str, help='Path to function file')#function
    parser.add_argument('-prompt', default='./auto_testcase/test_case_prompt.txt', type=str, help='Path to prompt function file')  #prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0] 
    module_name = module_info['moduleName']  # Module name
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_testcase: {module_name}")

    spec_path = paths['spec'].format(moduleName=module_name)
    func_file_path = args.func.format(module_name=module_name)

    # Read file contents
    with open(spec_path, 'r', encoding='utf-8') as spec_file:
        spec_content = spec_file.read()
    with open(func_file_path, 'r', encoding='utf-8') as funcf:
        func_content = funcf.read()
    with open(args.prompt, 'r', encoding='utf-8') as prompt_file:
        p_content = prompt_file.read()

    # Concatenate prompt
    prompt1 = (
        f'''{spec_content}'''
        f'''{func_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)


    output_file_name = f"./auto_testcase/{module_name}_testcase.txt"
    with open(output_file_name, 'w+', encoding='utf-8') as output_file:
        output_file.write(answer1)

