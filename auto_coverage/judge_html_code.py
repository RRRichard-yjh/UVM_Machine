
import os
from bs4 import BeautifulSoup
import re

def extract_coverage_data(soup):
    """Extracts various types of code coverage data."""
    coverage_data = {}

    # Line Coverage
    coverage_data["Line Coverage"] = [
        item.text.strip() for item in soup.find_all('font', color="red") 
        if "0/1" in item.text]

    # Conditional Coverage
    coverage_data["Conditional Coverage"] = []
    for row in soup.find_all("tr", class_="uRed"):
        if row.find(class_="lf"):
            code_line = row.find_previous("pre", class_="code")
            if code_line:
                text_content = code_line.get_text(strip=True)
                next_line = code_line.find_next_sibling()
                if next_line:
                    next_text_content = next_line.get_text(strip=True)
                    coverage_data["Conditional Coverage"].append(f"{text_content} | {next_text_content}")

    # Toggle Coverage
    coverage_data["Toggle Coverage"] = []
    for item in soup.find_all(class_="s3 cl"):
        prev_sibling = item.find_previous_sibling(lambda tag: tag.name == 'td' and not tag.has_attr('class'))
        if prev_sibling:
            coverage_data["Toggle Coverage"].append(f"{prev_sibling.text.strip()}: {item.text.strip()}")

    # FSM Coverage   
    coverage_data["FSM Coverage"] = []
    found_module = False  
    extracting = False    
    skip_first_table = False 

    for row in soup.find_all("tr"):
        if not found_module:
            if "FSM Coverage for Module" in row.get_text():
                found_module = True   
                skip_first_table = True
            continue     
        if skip_first_table:
            if "<caption>" in str(row) and "Summary for FSM :: state" in row.get_text():
                continue  
            else:
                skip_first_table = False  
        if found_module and not extracting:
            if "uRed" in row.get("class", []):
                extracting = True  
        if extracting:
            rows_to_extract = [row] + row.find_next_siblings("tr", limit=3)
            for r in rows_to_extract:
                cells = r.find_all("td")
                if len(cells) >= 3:  
                    transition = cells[0].get_text(strip=True)  
                    line_no = cells[1].get_text(strip=True)     
                    coverage_status = cells[2].get_text(strip=True)  
                    if "Not Covered" in coverage_status:  
                        coverage_data["FSM Coverage"].append(f"{transition} (Line {line_no}): {coverage_status}")
            break  


    # Branch Coverage
    coverage_data["Branch Coverage"] = []
    branch_coverage_element = soup.find(string=lambda text: "Branch Coverage for Module " in text)
    if branch_coverage_element:
        for item in branch_coverage_element.find_all_next('font', color="red"):
            red_text = item.get_text(strip=True)
            if "0/1" not in red_text and "1/1" not in red_text:
                previous_sibling = item.find_previous(string=True)
                if previous_sibling:
                    previous_line = previous_sibling.strip()
                    coverage_data["Branch Coverage"].append(previous_line)

    # Remove empty lists
    coverage_data = {k: v for k, v in coverage_data.items() if v}
    return coverage_data

def find_module_name(file_path):
    """Extracts the module name, prioritizing the title tag, then using regex as a fallback."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()  
            soup = BeautifulSoup(content, 'html.parser')
            title = soup.title.string
            if title:
                match = re.search(r"Module\s*:\s*([^<]+)", title)
                if match:
                    return match.group(1).strip()
            # If not found in title tag, use regex to search the file content
            match = re.search(r"Module\s+:\s+<a[^>]+>([^<]+)</a>", content)
            if match:
                return match.group(1).strip()
        return None
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return None
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
        return None

def process_html_file(file_path, module_name):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            soup = BeautifulSoup(file, 'html.parser')
            coverage_data = extract_coverage_data(soup)

            if coverage_data:
                for data_type, data_list in coverage_data.items():
                    file_name = f'./auto_coverage/uncovered_code/{data_type.replace(" ", "_").lower()}.txt'
                    with open(file_name, 'a', encoding='utf-8') as output_file:
                        output_file.write(f"--- Coverage data for {file_path} (Module: {module_name}) ---\n")
                        for item in data_list:
                            output_file.write(f"- {item}\n")
                        output_file.write("\n")
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")

def main():
    directory = './urgReport'
    output_directory = './auto_coverage/uncovered_code'
    
    # Clear output directory
    if os.path.exists(output_directory):
        for file in os.listdir(output_directory):
            os.remove(os.path.join(output_directory, file))
    else:
        os.makedirs(output_directory)

    html_files = [f for f in os.listdir(directory) if f.endswith('.html')]

    for html_file in html_files:
        file_path = os.path.join(directory, html_file)
        module_name = find_module_name(file_path)
        if module_name and "Top" not in module_name:
            process_html_file(file_path, module_name)
        elif module_name and "Top" in module_name:
            print(f"Excluding file: {file_path} (Module name contains 'Top')")

if __name__ == "__main__":
    main()

