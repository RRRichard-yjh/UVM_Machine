
import os
import json
import shutil
import re


def find_sv_files(directory):
    """Find all .sv files in the specified directory."""
    sv_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sv'):
                sv_files.append(os.path.join(root, file))
    return sv_files


def extract_class_content(file_path):
    """Extract content from class to endclass."""
    with open(file_path, 'r') as file:
        lines = file.readlines()

    class_content = []
    capture = False

    for line in lines:
        if 'class ' in line and 'extends' in line:
            capture = True
        if capture:
            class_content.append(line)
        if 'endclass' in line:
            capture = False

    return ''.join(class_content)


def extract_class_names(file_path):
    """Extract class names from .sv files where the line contains both 'class' and 'extends'."""
    class_names = []
    with open(file_path, 'r') as file:
        for line in file:
            if 'class ' in line and 'extends' in line:
                # Extract the class name using regex
                match = re.search(r'class\s+(\w+)\s+extends', line)
                if match:
                    class_names.append(match.group(1))
    return class_names


def append_to_file(file_path, content):
    """Append content to the specified file, adding two new lines before."""
    with open(file_path, 'a') as file:
        file.write('\n\n' + content)


def save_class_names(class_names, output_file):
    """Save class names to a .txt file."""
    with open(output_file, 'w') as file:
        for name in class_names:
            file.write(name + '\n')


def delete_sv_files(file_paths):
    """Delete all .sv files in the provided file paths."""
    for file_path in file_paths:
        try:
            os.remove(file_path)
            print(f"Deleted file: {file_path}")
        except OSError as e:
            print(f"Error deleting file {file_path}: {e}")


def main():
    # Load the module_info.json file
    with open('module_info.json', 'r') as file:
        data = json.load(file)

    module_name = data['modules'][0]['moduleName']
    uvm_testbench = data['modules'][0]['paths']['uvm_testbench'].format(moduleName=module_name)

    directories = ['./auto_add_seq/code', './auto_add_seq/function']

    sv_files = []
    for directory in directories:
        sv_files.extend(find_sv_files(directory))

    if sv_files:
        print("Having supplementary seq files:")
        for sv_file in sv_files:
            print(sv_file)

        seq_file_path = os.path.join(uvm_testbench, f"{module_name}_seq.sv")

        all_class_names = []
        for sv_file in sv_files:
            class_names = extract_class_names(sv_file)
            all_class_names.extend(class_names)

        output_txt_file = './auto_add_seq/new_seq_name.txt'
        save_class_names(all_class_names, output_txt_file)
        print(f"Class names saved to {output_txt_file}")

        for sv_file in sv_files:
            class_content = extract_class_content(sv_file)
            append_to_file(seq_file_path, class_content)

        delete_sv_files(sv_files)


if __name__ == "__main__":
    main()
