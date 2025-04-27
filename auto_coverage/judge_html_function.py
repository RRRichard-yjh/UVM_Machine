
from bs4 import BeautifulSoup

def extract_content(html):
    soup = BeautifulSoup(html, 'html.parser')
    results = []

    # Extract data for <a> tags with "name" attribute and related uncovered bins
    for a_tag in soup.find_all('a', {'name': True}):
        current_a_name = a_tag['name']
        uncovered_bins_found = False
        data = {'a_name': current_a_name, 'uncovered_bins': []}

        for sibling in a_tag.find_all_next():
            if sibling.name == 'a' and sibling.get('name'):
                break  

            if sibling.name == 'span' and sibling.get_text(strip=True) in ['Uncovered bins', 'Element holes']:
                uncovered_bins_found = True

            if uncovered_bins_found:
                if sibling.name == 'span' and sibling.get_text(strip=True) == 'Covered bins':
                    break

                if sibling.name == 'tr':
                    row_data = [td.get_text(strip=True) for td in sibling.find_all('td')]
                    if row_data:
                        data['uncovered_bins'].append(row_data)

        if uncovered_bins_found and data['uncovered_bins']:
            results.append(data)

    # Extract "SCORE" next row's first <td> content
    score_data = []
    for table in soup.find_all('table'):
        score_header = table.find('td', string=lambda x: x and 'SCORE' in x)  
        if score_header:
            next_row = score_header.find_parent('tr').find_next_sibling('tr')
            if next_row:
                first_td = next_row.find('td')
                if first_td:
                    score_data.append(first_td.get_text(strip=True))

    return results, score_data

with open('./urgReport/grp0.html', 'r', encoding='utf-8') as file:
    html_content = file.read()

extracted_data, score_data = extract_content(html_content)

# Output to text file
with open('./auto_coverage/uncovered_bins.txt', 'w', encoding='utf-8') as output_file:
    for item in extracted_data:
        output_file.write(f"A name: {item['a_name']}\n")
        output_file.write("Uncovered bins:\n")
        for row in item['uncovered_bins']:
            output_file.write(" | ".join(row) + "\n")
        output_file.write("\n")
    
    for score in score_data:
        output_file.write(f"{score}\n")

print("Data has been collected and saved to uncovered_bins.txt.")
