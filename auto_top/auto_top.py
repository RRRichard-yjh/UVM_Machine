
import re
import os
import argparse
import json
CLOCK_PATTERNS = [r'clk', r'clk_[\w]+', r'clock', r'CLK']
RESET_PATTERNS = [r'rst', r'rst_n', r'reset', r'reset_n',r'rst_[\w]+']

def preprocess_content(content):
    content = re.sub(r'//.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    content = re.sub(r'\s+', ' ', content).strip()  
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
                test_module,
                param_str,
                module_content  
            )

    raise ValueError(f"The specified module was not found: {test_module}")

def parse_parameters(param_str):
    params = {}
    if not param_str:
        return params

    param_re = re.compile(
        r'\bparameter\s+(?:integer|real|time|logic)?\s*(\w+)\s*=\s*([^,;)(]+)',
        re.IGNORECASE
    )
    raw_params = []  
    for match in param_re.finditer(param_str):
        param_name = match.group(1)
        param_value = match.group(2).strip().rstrip(');')  
        raw_params.append((param_name, param_value))

    computed_params = {}
    for param_name, param_value in raw_params:
        for p_name, p_value in computed_params.items():
            param_value = param_value.replace(p_name, str(p_value))
        try:
            computed_value = eval(param_value, {}, {})  
            computed_params[param_name] = computed_value
        except Exception as e:
            computed_params[param_name] = param_value  
    return computed_params

def remove_function_content(content):
    function_re = re.compile(r'function\s+.*?endfunction', re.DOTALL)
    return function_re.sub('', content)

def parse_ports(content):
    content = remove_function_content(content)  
    content = re.sub(r';', '; ', content)
    content = re.sub(r',', ', ', content)
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
    #print(ports)
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

def detect_special_signals(ports):
    clock, reset = None, None
    for port in ports:
        name = port['name']
        if any(re.fullmatch(p, name, re.I) for p in CLOCK_PATTERNS):
            clock = name
        if any(re.fullmatch(p, name, re.I) for p in RESET_PATTERNS):
            reset = name
    return clock, reset


def get_reset_level(module_name, module_info_json):
    with open(module_info_json, 'r') as f:
        data = json.load(f)
    for module in data['modules']:
        if module['moduleName'] == module_name:
            return module.get('reset_level', 'low')  
    return 'low'


def generate_clock_block(clock):
    clock_name = clock if clock else 'clk'
    return f"""
    initial begin
        ifc.{clock_name} = 0;
        forever #5 ifc.{clock_name} = ~ifc.{clock_name}; // 100MHz clock
    end
    """


def generate_reset_block(reset, reset_level):
    if reset:
        if reset_level == 'high':
            return f"""
    initial begin
        ifc.{reset} = 1;
        #100 ifc.{reset} = 0; // Reset for 100ns
    end
            """
        elif reset_level == 'low':
            return f"""
    initial begin
        ifc.{reset} = 0;
        #100 ifc.{reset} = 1; // Reset for 100ns
    end
            """
    return "// No reset signal detected"


def generate_dut_connection(ports):
    connections = []
    for port in ports:
        name = port['name']
        connections.append(f".{name}(ifc.{name})")
    return ',\n        '.join(connections)

def generate_param_list(params):
    if not params:
        return ""
    param_values = [str(params[param]) for param in params.keys()]
    return ','.join(param_values)

def generate_top(ports, module_name, test_module, params, reset_level):
    clock, reset = detect_special_signals(ports)
    param_list = generate_param_list(params)
    if param_list:
        param_list = f"#({param_list})"
    return f"""
module {module_name}_Top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Interface instantiation
    {module_name}_if ifc();
    
    // DUT instantiation
    {test_module} {param_list} dut (
        {generate_dut_connection(ports)}
    );

    // Clock and reset generation
    {generate_clock_block(clock)}
    {generate_reset_block(reset, reset_level)}

    // UVM configuration
    initial begin
        uvm_config_db#(virtual {module_name}_if)::set(null, "uvm_test_top", "vif", ifc);
        run_test("{module_name}_test");  
    end

    // Waveform recording
    initial begin
        $fsdbDumpfile("sim.fsdb");
        $fsdbDumpvars();
    end

endmodule
    """


def parse_dut_ports(dut_file, test_module):
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
    test_module = module_info.get('topModule', module_name)
    test_name = f"{module_name}_test"
    reset_level = module_info.get('reset_level', 'None')
    dut_path = module_info['paths']['dut'].format(moduleName=module_name)

    try:
        ports, parsed_module_name, params = parse_dut_ports(dut_path, test_module)
        top_code = generate_top(
            ports, 
            module_name=module_name,    
            test_module=test_module,    
            params=params, 
            reset_level=reset_level
        )
        output_file_name = f"./auto_top/{module_name}_Top.sv"
        os.makedirs(os.path.dirname(output_file_name), exist_ok=True)
        with open(output_file_name, 'w', encoding='utf-8') as output_file:
            output_file.write(top_code)
        print(f"Generated successfully: {os.path.normpath(output_file_name)}")
    except Exception as e:
        print(f"Generation failed: {str(e)}")
