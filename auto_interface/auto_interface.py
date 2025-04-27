
import re
import argparse
import os
import json
import ast

if os.sys.stdout.encoding != 'UTF-8':
    os.sys.stdout = open(os.sys.stdout.fileno(), mode='w', encoding='utf-8', buffering=1)
    os.sys.stderr = open(os.sys.stderr.fileno(), mode='w', encoding='utf-8', buffering=1)

CLOCK_PATTERNS = [r'clk', r'clk_[\w]+', r'clock', r'CLK']


def preprocess_content(content):
    content = re.sub(r'//.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    content = re.sub(r'\s+', ' ', content).strip()  
    # print(content)
    return content

def parse_module_declaration(content, test_module):
    module_re = re.compile(
        r'module\s+(\w+)\s*(#\s*\((.*?)\))?\s*\((.*?)\)\s*;',
        re.DOTALL | re.IGNORECASE
    )
    for match in module_re.finditer(content):
        module_name = match.group(1)
        if module_name == test_module:
            start_index = match.start()
            end_index = content.find('endmodule', start_index) + len('endmodule')
            module_content = content[start_index:end_index]

            param_str = match.group(2) or ''

            outside_param_re = re.compile(
                r'\bparameter\s+(\w+)\s*=\s*([^;]+)\s*;',
                re.IGNORECASE
            )
            for outside_match in outside_param_re.finditer(module_content):
                param_str += f"parameter {outside_match.group(1)} = {outside_match.group(2)};"

            return (
                module_name,
                param_str,
                module_content  
            )

    raise ValueError(f"The specified module was not found: {test_module}")


def parse_parameters(content):
    params = {}

    def extract_and_parse_param_part(part_str):
        local_params = {}
        if not part_str:
            return local_params
        param_re = re.compile(
            r'\bparameter\s+(?:integer|real|time|logic)?\s*(\w+)\s*=\s*([^,;]+?(?:\([^)]*\))*?)(?=[,;]|$)',
            re.IGNORECASE
        )
        #print(f"warn：{param_re}")
        for match in param_re.finditer(part_str):
            param_name = match.group(1)
            param_value = match.group(2).strip()
            param_value = param_value.rstrip(');')
            
            try:
                param_value = int(param_value)
            except ValueError:
                try:
                    param_value = float(param_value)
                except ValueError:
                    pass  
            
            local_params[param_name] = param_value
            print(f"This parameter name：{param_name}，This parameter value：{param_value}")
        return local_params

    start_index = content.find('# (') if (content.find('#(') == -1) else content.find('#(')
    end_index = content.find(')', start_index)
    param_str = content[start_index + 2:end_index] if start_index != -1 and end_index != -1 else ""

    outer_param_str = content[end_index + 1:]

    print(f"{start_index}")

    params_in_parentheses = extract_and_parse_param_part(param_str)
    params_outside_parentheses = extract_and_parse_param_part(outer_param_str)

    params = {**params_in_parentheses, **params_outside_parentheses}
    return params

def remove_function_content(content):
    function_re = re.compile(r'function\s+.*?endfunction', re.DOTALL)
    return function_re.sub('', content)

def parse_ports(content):
    content = remove_function_content(content)  
    content = re.sub(r';', '; ', content)
    content = re.sub(r',', ', ', content)
    # print(content)
    ports = []
    index = 0
    nesting_level = 0  
    width_level = 0    
    width_info = ''    

    while index < len(content):
        if content[index] == '(':
            nesting_level += 1
        elif content[index] == ')':
            nesting_level -= 1
        elif content[index] == '[':
            width_level += 1
            width_start = index
        elif content[index] == ']':
            width_level -= 1
            if width_level == 0:
                width_info = content[width_start:index + 1]

        if content[index:].startswith(" input ") or content[index:].startswith(" output ") or content[index:].startswith(",input ") or content[index:].startswith(",output "):
            if content[index:].startswith(" input "):
                direction = "input"
                index += len(" input ")
            elif content[index:].startswith(" output "):
                direction = "output"
                index += len(" output ")
            elif content[index:].startswith(",input "):
                direction = "input"
                index += len(",input ")
            elif content[index:].startswith(",output "):
                direction = "output"
                index += len(",output ")

            while content[index:].startswith(("reg ", "wire ", "signed ", "logic ")):
                if content[index:].startswith("reg "):
                    index += len("reg ")
                elif content[index:].startswith("wire "):
                    index += len("wire ")
                elif content[index:].startswith("signed "):
                    index += len("signed ")
                elif content[index:].startswith("logic "):
                    index += len("logic ")

            if nesting_level == 0:
                end_chars = [';']
            else:
                end_pattern = r'(?=,\s*(?:input|output)\s)|(?=\))'

            start = index
            if nesting_level == 0:
                end_index = index
                while end_index < len(content) and content[end_index] not in end_chars:
                    end_index += 1
            else:
                end_match = re.search(end_pattern, content[index:])
                if end_match:
                    end_index = index + end_match.start()
                else:
                    end_index = len(content)

            scope_content = content[start:end_index]
            width_match = re.search(r'\[.*?\]', scope_content)
            if width_match:
                width_info = width_match.group(0)
            else:
                width_info = ''

            variable_str = content[start:end_index]
            variables = [var.strip() for var in variable_str.split(',') if var.strip()]
            for var in variables:
                port_name = re.sub(r'\[.*?\]', '', var).strip()
                ports.append({
                    'direction': direction,
                    'type': 'logic',
                    'width': width_info,
                    'name': port_name
                })
            width_info = ''  
            index = end_index + 1
        else:
            index += 1
    # print(ports)
    return ports

def replace_width_params(ports, params):
    for port in ports:
        width = port['width']

        for param_name, param_value in params.items():
            width = width.replace(param_name, str(param_value))

        width = re.sub(r'\s*([+-/*])\s*', r'\1', width)  
        width = width.replace(" ", "")  

        def replace_expr(match):
            original = match.group(0)
            content = match.group(1).strip()

            if not content:
                return original  

            if ':' in content:
                parts = []
                for part in content.split(':'):
                    part = part.strip()
                    if part:
                        try:
                            
                            result = eval(part, {}, params)
                            parts.append(str(result))
                        except Exception as e:
                            parts.append(part)
                    else:
                        parts.append('')  
                return f"[{':'.join(parts)}]"

            try:
                result = eval(content, {}, params)
                return f"[{str(result)}]"
            except Exception as e:
                return original  

        width = re.sub(r'\[([^]]+)\]', replace_expr, width)

        port['width'] = width

    return ports


def generate_interface(ports, module_name, params):
    has_clock = False
    for port in ports:
        if port['direction'] == 'input':
            for pattern in CLOCK_PATTERNS:
                if re.search(pattern, port['name']):
                    has_clock = True
                    break
            if has_clock:
                break

    if not has_clock:
        new_port = {
            'direction': 'input',
            'type': 'logic',
            'width': '',
            'name': 'clk'
        }
        ports.append(new_port)

    signal_decl = ""
    input_ports = []
    output_ports = []
    unique_ports = []
    for port in ports:
        if port not in unique_ports:
            unique_ports.append(port)
            signal_decl += f"    logic {port['width']} {port['name']};\n"
            if port['direction'] == 'input':
                input_ports.append(port['name'])
            elif port['direction'] == 'output':
                output_ports.append(port['name'])

    modport_decl = f"""
    modport DUT (
    input {', '.join(input_ports)},
    output {', '.join(output_ports)}
    );//design modport
    """

    return f"""

interface {module_name}_if();

//input/output signals
{signal_decl}
{modport_decl}
endinterface //{module_name} design interface
"""


def parse_dut_ports(dut_file):
    with open(dut_file, 'r', encoding='utf-8') as f:
        raw_content = f.read()

    content = preprocess_content(raw_content)

    try:
        module_name, param_str, module_content = parse_module_declaration(content, test_module)
    except Exception as e:
        raise ValueError(f"Failed: {str(e)}")

    params = parse_parameters(param_str)

    ports = parse_ports(module_content)  

    ports = replace_width_params(ports, params)

    return ports, module_name, params


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Configure UVM interface files based on JSON files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='JSON configuration file path')

    args = parser.parse_args()

    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)

    module_info = config['modules'][0]
    module_name = module_info['moduleName']  
    test_module = module_info['topModule']
    paths = module_info['paths']  

    dut_path = paths['dut'].format(moduleName=module_name)

    try:
        ports, parsed_module_name, params = parse_dut_ports(dut_path)

        output_file_name = f"./auto_interface/{module_name}_if.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(generate_interface(ports, module_name, params))
        print(f"Generated successfully: {os.path.normpath(output_file_name)}")
    except Exception as e:
        print(f"Generation failed: {str(e)}")
