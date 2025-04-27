
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
    
	# Use argparse to get the JSON configuration file path
    parser = argparse.ArgumentParser(description='Script for handling JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file') #json
    parser.add_argument('-exfun', default='./auto_function/example_function.txt', type=str, help='Path to example function file') #example_function
    parser.add_argument('-prompt', default='./auto_function/prompt_function.txt', type=str, help='Path to prompt function file')  #prompt

    args = parser.parse_args()

    # Read the JSON configuration file
    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0] 
    module_name = module_info['moduleName']  # Module name
    paths = module_info['paths']  # Path information
    print(f"Extracted module_name in auto_function: {module_name}")

    spec_path = paths['spec'].format(moduleName=module_name)

    # Read file contents
    with open(spec_path, 'r', encoding='utf-8') as spec_file:
        spec_content = spec_file.read()
    with open(args.exfun, 'r', encoding='utf-8') as exfun_file:
        ex_content = exfun_file.read()
    with open(args.prompt, 'r', encoding='utf-8') as prompt_file:
        p_content = prompt_file.read()

    # Concatenate prompt
    prompt1 = (
        f'''{spec_content}'''
        f'''{ex_content}'''
        f'''{p_content}'''
    )

    answer1 = get_request(prompt1)
    print(answer1)


    output_file_name = f"./auto_function/{module_name}_function.txt"
    with open(output_file_name, 'w+', encoding='utf-8') as output_file:
        output_file.write(answer1)

