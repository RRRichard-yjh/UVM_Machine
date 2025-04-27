
from bs4 import BeautifulSoup
import os

filename = './auto_coverage/extracted_coverage_data.txt'

if os.path.exists(filename):
    print(f"{filename} exists, deleting it...")
    os.remove(filename)
    print(f"{filename} has been deleted.")



open(filename, 'w').close()

# Load and parse the HTML content
with open('./urgReport/hierarchy.html', 'r') as file:
    html_content = file.read()
soup = BeautifulSoup(html_content, 'html.parser')

# Find all rows in the table with a specific data-tt-id attribute (to exclude the root)
rows = soup.find_all('tr', attrs={"data-tt-id": lambda x: x and x != "hierarchyTable_root"})

# Determine the update sequence
with open(filename, 'r') as file:
    content = file.readlines()
    update_count = sum(1 for line in content if line.startswith("# the")) + 1
    update_text = f"# the {update_count}\n"

# Append new data to the file
with open(filename, 'a') as file:
    if os.path.getsize(filename) > 0:
        file.write("\n\n\n")
        file.write(update_text)
    seen_names = set()
    for row in rows:
        name = row.find('a').text.strip()
        if name in seen_names:
            continue
        if any(keyword in name for keyword in ["Top", "dut", "uut"]):
            seen_names.add(name)
            score, line, cond, toggle, fsm, branch = (td.text.strip() for td in row.find_all('td')[1:7])
            file.write(f"name:{name} SCORE:{score}% LINE:{line}% COND:{cond}% TOGGLE:{toggle}% FSM:{fsm}% BRANCH:{branch}%\n")

with open(filename, 'r') as file:
    content = file.read()
    print(content)

